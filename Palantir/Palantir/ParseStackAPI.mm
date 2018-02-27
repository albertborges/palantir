//
//  ParseStackAPI.cpp
//  Palantir
//
//  Created by Albert Borges on 2/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#include <string>
#include <vector>
#include <array>
#include "ParseStackAPI.h"
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>

static std::string exec(const char* cmd) {
   std::array<char, 128> buffer;
   std::string result;
   
   NSBundle* thisBundle = [NSBundle mainBundle];
   NSString* setupEnlistmentPath;
   setupEnlistmentPath = [thisBundle pathForResource:@"setupEnlistment" ofType:@"sh"];
   const char* setupEnlistmentPathCStr = [setupEnlistmentPath cStringUsingEncoding:[NSString defaultCStringEncoding]];

   NSString* listEnlistmentsPath;
   listEnlistmentsPath = [thisBundle pathForResource:@"list_enlistments" ofType:@"sh"];
   const char* listEnlistmentsPathCStr = [listEnlistmentsPath cStringUsingEncoding:[NSString defaultCStringEncoding]];
   
   const char* cmd1a = "ALL_ENLISTMENTS=$(\0";
   const char* cmd1c = ")\0";
   const char* cmdcat = " && \0";
   
   unsigned long cmd1size = strlen(cmd1a) + strlen(listEnlistmentsPathCStr) + strlen(cmd1c) + strlen(cmdcat);
   
   std::vector< std::string > cmds;
   int cmdlength = 0;

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
   
   strcat(cmdbuffer, cmd1a);
   strcat(cmdbuffer, listEnlistmentsPathCStr);
   strcat(cmdbuffer, cmd1c);
   strcat(cmdbuffer, cmdcat);
   for(int i=0; i<cmds.size();i++)
      strcat(cmdbuffer, cmds[i].c_str());
   strcat(cmdbuffer, cmd);
   strcat(cmdbuffer, "\0");
   
   std::shared_ptr<FILE> pipe(popen(cmdbuffer, "r+"), pclose);
   
   if (!pipe) throw std::runtime_error("popen() failed!");
   while (!feof(pipe.get())) {
      if (fgets(buffer.data(), 128, pipe.get()) != nullptr)
         result += buffer.data();
   }
   return result;
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

std::vector< ChangeList > ParseXcodeStack( NSString* stackData, NSDateComponents* startTime, NSDateComponents* endTime )
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
   
   printf("%s", exec("sd changes -m 5 oart/text/linelayout.cpp\0").c_str());
   
   
   // sd changes -m 5 /Users/albertborges/sd/dev/richedit/src/OLS.CPP
   return ParseStackDummyData();
}

std::vector< ChangeList > ParseTimeProfilerStack( NSString* stackData, NSDateComponents* start, NSDateComponents* end )
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
   
   printf("%s", exec("sd changes -m 5 oart/text/linelayout.cpp\0").c_str());
   
   
   // sd changes -m 5 /Users/albertborges/sd/dev/richedit/src/OLS.CPP
   return ParseStackDummyData();
}

