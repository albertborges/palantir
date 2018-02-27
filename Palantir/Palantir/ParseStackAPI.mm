//
//  ParseStackAPI.cpp
//  Palantir
//
//  Created by Albert Borges on 2/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#include <array>
#include "ParseStackAPI.h"
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>

static std::vector<std::string> splitbycomponent(std::string buffer, std::string delimeter)
{
   size_t index = buffer.find(delimeter);
   std::vector<std::string>tokens;
   while(index != std::string::npos)
   {
      std::string token = buffer.substr(0, index);
      buffer = buffer.substr(index+delimeter.size());
      index = buffer.find(delimeter);
      tokens.push_back(token);
   }
   tokens.push_back(buffer);
   return tokens;
}

static Error exec(const char* cmd, std::string& terminaloutput) {
   std::array<char, 128> buffer;
   std::string result;
   NSBundle* thisBundle = [NSBundle mainBundle];
   
   NSString* listEnlistmentsPath;
   listEnlistmentsPath = [thisBundle pathForResource:@"list_enlistments" ofType:@"sh"];
   const char* listEnlistmentsPathCStr = [listEnlistmentsPath cStringUsingEncoding:[NSString defaultCStringEncoding]];
   
   const char* cmd1a = "ALL_ENLISTMENTS=$(\0";
   const char* cmd1c = ")\0";
   const char* cmdcat = " && \0";
   
   unsigned long cmd1size = strlen(cmd1a) + strlen(listEnlistmentsPathCStr) + strlen(cmd1c) + strlen(cmdcat);
   
   std::vector< std::string > cmds;
   int cmdlength = 0;
   
   NSString* setupEnlistmentPath;
   setupEnlistmentPath = [thisBundle pathForResource:@"setupEnlistment" ofType:@"sh"];
   const char* setupEnlistmentPathCStr = [setupEnlistmentPath cStringUsingEncoding:[NSString defaultCStringEncoding]];
   
   std::ifstream myfile (setupEnlistmentPathCStr);
   std::string line;
   if (myfile.is_open())
   {
      while ( getline (myfile,line) )
      {
         cmds.push_back(line);
         cmds.push_back(cmdcat);
         cmdlength += line.length();
         cmdlength += strlen(cmdcat);
      }
      myfile.close();
   }
   
   char* cmdbuffer = (char*)malloc(cmd1size+cmdlength+strlen(cmd)+1);
   
   // Load listEnlistment.sh in the command buffer
   strcat(cmdbuffer, cmd1a);
   strcat(cmdbuffer, listEnlistmentsPathCStr);
   strcat(cmdbuffer, cmd1c);
   strcat(cmdbuffer, cmdcat);
   
   // Load all the commands in setupEnlistment.sh in the command buffer
   for(int i=0; i<cmds.size();i++)
   strcat(cmdbuffer, cmds[i].c_str());
   
   // Load the paramter command in the command buffer
   strcat(cmdbuffer, cmd);
   strcat(cmdbuffer, "\0");
   
   // Run the commands
   std::shared_ptr<FILE> pipe(popen(cmdbuffer, "r+"), pclose);
   
   if (!pipe) throw std::runtime_error("popen() failed!");
   while (!feof(pipe.get())) {
      if (fgets(buffer.data(), 128, pipe.get()) != nullptr)
      result += buffer.data();
   }
   
   terminaloutput = result;
   
   if(terminaloutput.find("User not authenticated.\n") != std::string::npos)
      return Error::CredentialInitializationNeeded;
   else if(terminaloutput.find("Connect to server failed") != std::string::npos)
      return Error::NoCorpConnectivity;
   
   std::vector<std::string>terminaloutputvec = splitbycomponent(result, "Enlistment has been initialized successfully!\n");
   
   terminaloutput = terminaloutputvec[1];
   
   delete cmdbuffer;
   
   return Error::NoError;
}

static Error callsdchanges(NSArray* files, std::vector<SDResult>& results)
{
   NSMutableString* cmd = [[NSMutableString alloc] init];
   for(NSString* file : files)
   {
      [cmd appendString:@"sd changes "];
      [cmd appendString:file];
      [cmd appendString:@" 2>&1"];
      [cmd appendString:@" && "];
      [cmd appendString:@"echo '###PALANTIRCOMPONENT###'"];
      [cmd appendString:@" && "];
   }
   [cmd appendString:@"echo '###PALANTIRCOMPONENT###'"];
   
   std::string terminalouput;
   Error status = exec([cmd cStringUsingEncoding:[NSString defaultCStringEncoding]], terminalouput);
   
   std::vector<std::string> filehistories = splitbycomponent(terminalouput, "###PALANTIRCOMPONENT###");
   
   for(int i=(int)filehistories.size()-1; i>=0;i--)
      if(filehistories[i].find("Change") == std::string::npos)
         filehistories.erase(filehistories.begin() + i);
   
   if( [files count] != filehistories.size() )
      return FileResultMappingError;
   
   std::vector<SDResult> rvec;
   for(int i=0;i<filehistories.size();i++)
   {
      SDResult* result = new SDResult();
      File* file = new File();
      file->filename = [[files objectAtIndex:i] cStringUsingEncoding:[NSString defaultCStringEncoding]];
      file->culpable = true;
      result->file = *file;
      result->filehistory = filehistories[i];
      rvec.push_back(*result);
   }
   results = rvec;
   return status;
}

static bool PossibleCulpableChangeListGivenTimeInterval( std::string date, std::string hmstime, NSDateComponents* start, NSDateComponents* end )
{
   std::vector<std::string> datecomponents = splitbycomponent(date, "/");
   std::vector<std::string> hmstimecomponents = splitbycomponent(hmstime, ":");
   
   NSDateComponents *changelisttimecomponents = [[NSDateComponents alloc] init];
   [changelisttimecomponents setYear:std::stoi(datecomponents[0])];
   [changelisttimecomponents setMonth:std::stoi(datecomponents[1])];
   [changelisttimecomponents setDay:std::stoi(datecomponents[2])];
   [changelisttimecomponents setHour:std::stoi(hmstimecomponents[0])];
   [changelisttimecomponents setMinute:std::stoi(hmstimecomponents[1])];
   [changelisttimecomponents setSecond:std::stoi(hmstimecomponents[2])];
   
   NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   NSDate *datestart = [gregorianCalendar dateFromComponents:start];
   NSDate *dateend = [gregorianCalendar dateFromComponents:end];
   NSDate *datechangelist = [gregorianCalendar dateFromComponents:changelisttimecomponents];
   
   if ([datechangelist compare:datestart] == NSOrderedDescending && [datechangelist compare:dateend] == NSOrderedAscending) {
      return true;
   }
   
   return false;
}

static std::string RemoveEnlistmentFromAliasString( std::string& aliasstring )
{
   std::vector<std::string> aliasstringvec = splitbycomponent(aliasstring, "@");
   return aliasstringvec[0];
}

static std::vector<ChangeList> ParseSDResult(SDResult result, NSDateComponents* start, NSDateComponents* end)
{
   std::vector<ChangeList>changeLists;
   std::vector<std::string> changes = splitbycomponent(result.filehistory, "\n");
   
   int size = (int)changes.size();
   for(int i=size-1;i>=0;i--)
   {
      if(changes[i].find("Change") == std::string::npos)
         changes.erase(changes.begin() + i);
   }
   
   for(std::string change : changes)
   {
      std::vector<std::string> changeinfo = splitbycomponent(change, " ");
      std::string changedate = changeinfo[3] + " " + changeinfo[4];
      if( PossibleCulpableChangeListGivenTimeInterval(changeinfo[3], changeinfo[4], start, end) )
      {
         ChangeList* cl = new ChangeList();
         cl->identifier = stoi(changeinfo[1]);
         std::string author = RemoveEnlistmentFromAliasString(changeinfo[6]);
         cl->author = author;
         
         std::vector< File > files;
         files.push_back(result.file);
         cl->files = files;
         
         changeLists.push_back(*cl);
      }
   }
   
   return changeLists;
}

/* Used to merge changelists. Sometimes duplicate changelists result from multiple calls to ParseSDResult because the same changelist could have touched multiple culpable files */
static void mergeChangeLists( std::vector<ChangeList>& changelists )
{
   std::map <int, ChangeList> changelist_map;
   
   for( ChangeList change : changelists )
   {
      if( changelist_map.find(change.identifier) == changelist_map.end() )
      {
         changelist_map[change.identifier] = change;
      }
      else
      {
         ChangeList existingchange = changelist_map[change.identifier];
         existingchange.files.insert(existingchange.files.end(), change.files.begin(), change.files.end());
         changelist_map[existingchange.identifier] = existingchange;
      }
   }
   
   changelists.clear(); // TODO BOALBE, call delete on each element
   for( auto const& x : changelist_map )
   {
      changelists.push_back(x.second);
   }
}

static std::string TruncateFilePathFileString(std::string file)
{
   return file.substr(file.find_last_of("/")+1);
}

static void concatenateNonCulpabaleChangeListFiles( std::vector<ChangeList>& changelists )
{
   std::array<char, 128> buffer;
   std::string result;
   
   std::string cmdbuffer;

   for(ChangeList change : changelists)
   {
      std::string cmd = "sd describe -s " + std::to_string(change.identifier) + " && echo '###PALANTIRCOMPONENT###' && ";
      cmdbuffer += cmd;
   }
   cmdbuffer += "echo '###PALANTIRCOMPONENT###'";
   
   std::string terminaloutput;
   exec(cmdbuffer.c_str(), terminaloutput);
   
   std::vector<std::string> changedescriptions = splitbycomponent(terminaloutput, "###PALANTIRCOMPONENT###");
   
   for(int i=changedescriptions.size()-1;i>=0;i--)
   {
      if(changedescriptions[i].find("Affected files ...") == std::string::npos)
         changedescriptions.erase(changedescriptions.begin() + i);
   }
   
   for(int i=0;i<changedescriptions.size();i++)
   {
      const char* delimeter = "Affected files ...";
      std::vector<std::string>parseddescribeoutputvec = splitbycomponent(changedescriptions[i], delimeter);
      std::string files = parseddescribeoutputvec[1];
      std::vector<std::string>parsedfilesoutputvec = splitbycomponent(files, "\n");
      
      for(int j=(int)parsedfilesoutputvec.size()-1;j>=0;j--)
      {
         if(parsedfilesoutputvec[j].find("... //") == std::string::npos)
         parsedfilesoutputvec.erase(parsedfilesoutputvec.begin() + j);
      }
      
      std::vector<File> newfiles;
      std::vector<std::string> oldfilesstr;
      
      for( File f : changelists[i].files )
      {
         oldfilesstr.push_back(f.filename);
      }
      
      
      std::vector<std::string> oldfilestruncated = oldfilesstr;
      for(int j=0;j<oldfilestruncated.size();j++)
      {
         std::string fname = TruncateFilePathFileString(oldfilestruncated[j]);
         oldfilestruncated[j] = fname;
      }
      
      changelists[i].files.clear(); // TODO BOALBE MEMORY LEAK!
      for(int j=0;j<parsedfilesoutputvec.size();j++)
      {
         const char* prefix = "... ";
         File* f = new File(); // TODO BOALBE
         f->filename = parsedfilesoutputvec[j].substr(strlen(prefix));
         f->culpable = false;
         
         std::string newfiletruncated = TruncateFilePathFileString(f->filename);
         newfiletruncated = splitbycomponent(newfiletruncated, "#")[0];
         if(std::find(oldfilestruncated.begin(), oldfilestruncated.end(), newfiletruncated) != oldfilestruncated.end())
         {
            f->culpable = true;
         }
         
         newfiles.push_back(*f);
      }
      
      changelists[i].files = newfiles;
   }
}

static std::vector< ChangeList > ParseStackDummyData()
{
   /*
    PARSING...
    */

   // IGNORE MEMORY LEAKS. PURELY FOR EXAMPLE PURPOSES. WILL USE SMART POINTERS LATER.
   struct File* file1obj = new File();
   std::string file1 = "/Users/albertborges/sd/dev/oart/text/linelayout.cpp";
   file1obj->filename  = file1;
   file1obj->culpable = true;
   
   struct File* file2obj = new File();
   std::string file2 = "/Users/albertborges/sd/dev/oart/text/test/Text_ut.cpp";
   file2obj->filename  = file2;
   file2obj->culpable = false;
   
   struct File* file3obj = new File();
   std::string file3 = "/Users/albertborges/sd/dev/oart/text/txlayoutre.cpp";
   file3obj->filename  = file1;
   file3obj->culpable = false;
   
   std::vector< struct File >* files = new std::vector< struct File >();
   files->push_back(*file1obj);
   files->push_back(*file2obj);
   files->push_back(*file3obj);
   
   struct ChangeList* cl = new ChangeList();
   cl->identifier = 16263717;
   cl->files = *files;
   cl->author = "boalbe";
   
   std::vector< ChangeList > changelists;
   changelists.push_back(*cl);
   
   return changelists;
}

static Error RunSDCommands( NSArray* files, NSDateComponents* start, NSDateComponents* end, std::vector< ChangeList >& changelists, IUIUpdater* updater = nullptr )
{
   if(updater)
   updater->UpdateUIOnStartingSDFileHistory();
   std::vector<SDResult> results;
   Error status = callsdchanges(files, results);
   
   if( status != NoError )
   return status;
   
   if(updater)
   updater->UpdateUIOnFinishingSDFileHistory();
   
   if(updater)
   updater->UpdateUIOnStartingScanningOfFileHistories();
   std::vector<ChangeList> changelistsFound;
   for( SDResult result : results)
   {
      std::vector<ChangeList> temp = ParseSDResult(result, start, end);
      changelistsFound.insert( changelistsFound.end(), temp.begin(), temp.end() );
   }
   mergeChangeLists(changelistsFound);
   if(updater)
   updater->UpdateUIOnEndingScanningOfFileHistories();
   
   if(updater)
   updater->UpdateUIOnStartingGettingInfoOnPossibleCulpableChangelists();
   concatenateNonCulpabaleChangeListFiles(changelistsFound);
   if(updater)
   updater->UpdateUIOnEndingGettingInfoOnPossibleCulpableChangelists();
   
   changelists = changelistsFound;
   
   return NoError;
}

Error ParseXcodeStack( NSString* stackData, NSDateComponents* startTime, NSDateComponents* endTime, std::vector< ChangeList >& changelists, IUIUpdater* updater )
{
   NSArray* frames = [stackData componentsSeparatedByString:@"#"];
   NSMutableArray* files = [[NSMutableArray alloc] init];
   
   // Extract the filenames from the stack
   for( int i = 0; i < [frames count]; i++ )
   {
      NSString* frame = frames[i];
      NSRange range = [frame rangeOfString:@" at "];
      
      if(range.length != 0)
      {
         NSInteger index = range.location+4;
         NSRange fileRange = NSMakeRange(index, [frame length] - index);
         
         NSString* filenameWithLineNumber = [frame substringWithRange:fileRange];
         
         NSArray* filenameWithLineNumberComponents = [filenameWithLineNumber componentsSeparatedByString:@":"];
         
         NSString* filename = filenameWithLineNumberComponents[0];
         [files addObject:filename];
      }
   }
   
   return RunSDCommands(files, startTime, endTime, changelists);
}

Error ParseTimeProfilerStack( NSString* stackData, NSDateComponents* startTime, NSDateComponents* endTime, std::vector< ChangeList >& changelists, IUIUpdater* updater )
{
   NSArray* frames = [stackData componentsSeparatedByString:@"\n"];
   NSMutableArray* files = [[NSMutableArray alloc] init];
   
   // Extract the filenames from the stack
   for( int i = 0; i < [frames count]; i++ )
   {
      NSString* frame = frames[i];
      NSRange range = [frame rangeOfString:@" /"];
      
      if(range.length != 0)
      {
         NSInteger index = range.location+1;
         NSRange fileRange = NSMakeRange(index, [frame length] - index);
         
         NSString* filenameWithLineNumber = [frame substringWithRange:fileRange];
         
         NSArray* filenameWithLineNumberComponents = [filenameWithLineNumber componentsSeparatedByString:@":"];
         
         NSString* filename = filenameWithLineNumberComponents[0];
         [files addObject:filename];
      }
   }
   
   return RunSDCommands(files, startTime, endTime, changelists);
}



