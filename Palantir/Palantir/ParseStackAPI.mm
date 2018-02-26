//
//  ParseStackAPI.cpp
//  Palantir
//
//  Created by Albert Borges on 2/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#include <string>
#include <vector>
#include "ParseStackAPI.h"

std::vector< ChangeList* >* ParseXcodeStack( NSString* stackData, NSDateComponents* startTime, NSDateComponents* endTime )
{
   /*
    PARSING...
    */
   
   // IGNORE MEMORY LEAKS. PURELY FOR EXAMPLE PURPOSES. WILL USE SMART POINTERS LATER.
   struct ChangeList* cl = new ChangeList();
   cl->identifier = 16263717;
   
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
   
   std::vector< struct File* >* files = new std::vector< struct File* >();
   files->push_back(file1obj);
   files->push_back(file2obj);
   files->push_back(file3obj);
   
   std::vector< ChangeList* >* changelists = new std::vector< ChangeList* >();
   changelists->push_back(cl);
   
   return changelists;
}

std::vector< ChangeList* >* ParseTimeProfilerStack( NSString* stackData, NSDate* start, NSDate* end )
{
   /*
    PARSING...
    */
   
   // IGNORE MEMORY LEAKS. PURELY FOR EXAMPLE PURPOSES. WILL USE SMART POINTERS LATER.
   struct ChangeList* cl = new ChangeList();
   cl->identifier = 16263717;
   
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
   
   std::vector< struct File* >* files = new std::vector< struct File* >();
   files->push_back(file1obj);
   files->push_back(file2obj);
   files->push_back(file3obj);
   
   std::vector< ChangeList* >* changelists = new std::vector< ChangeList* >();
   changelists->push_back(cl);
   
   return changelists;
}

