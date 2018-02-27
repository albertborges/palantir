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
      [cmd appendString:@"echo '###'"];
      [cmd appendString:@" && "];
   }
   [cmd appendString:@"echo '###'"];
   
   std::string terminalouput;
   Error status = exec([cmd cStringUsingEncoding:[NSString defaultCStringEncoding]], terminalouput);
   
   std::vector<std::string> filehistories = splitbycomponent(terminalouput, "###");
   
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
   
   return changeLists;
}

/* Used to merge changelists. Sometimes duplicate changelists result from multiple calls to ParseSDResult because the same changelist could have touched multiple culpable files */
static void mergeChangeLists( std::vector<ChangeList>& changelists )
{
   // TODO
}

static void concatenateNonCulpabaleChangeListFiles( std::vector<ChangeList>& changelists )
{
   // TODO
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
   
//   std::string buffer = callsdchanges(files);
//   std::vector<string>
// sd changes -m 5 /Users/albertborges/sd/dev/richedit/src/OLS.CPP

   changelists = ParseStackDummyData();
   return NoError;
}

Error ParseTimeProfilerStack( NSString* stackData, NSDateComponents* start, NSDateComponents* end, std::vector< ChangeList >& changelists, IUIUpdater* updater )
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
   
   concatenateNonCulpabaleChangeListFiles(changelistsFound);

   changelists = ParseStackDummyData();

   return NoError;
}

