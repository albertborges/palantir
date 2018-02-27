//
//  ViewController.m
//  Palantir
//
//  Created by Albert Borges on 2/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ViewController.h"
#include <string>
#include <vector>
#include "ParseStackAPI.h"

@implementation ViewController

- (void)viewDidLoad {
   [super viewDidLoad];

   // Do any additional setup after loading the view.
   
//   NSString* xcodeStack = @"#0   0x000000011827e492 in Ptls6::ols::FetchRun(int, int, Ptls6::lsstyle*, wchar_t const**, int*, bool*, Ptls6::lschp*, unsigned short*, Ptls6::lsrun**, int, Ptls6::lsspanqualifierInfo const&, bool&) at /Users/albertborges/sd/dev/richedit/src/OLS.CPP:4198#1   0x000000011828562d in OlsFetchRun(Ptls6::ols*, Ptls6::lsparaclient*, Ptls6::lsspan_struct, int, int, Ptls6::lsstyle*, Ptls6::lsfetchposition, Ptls6::lsfetchresult*) at /Users/albertborges/sd/dev/richedit/src/OLS.CPP:5613#2   0x000000011772b330 in Ptls6::LsQuickFormatting(Ptls6::CLsSubline*, Ptls6::lsformatcontext*, int, int*, int*, int*, int*, int*, int*, Ptls6::lsfetchresult*) at /Users/albertborges/sd/dev/PTLS/LS/src/LSFETCH.CPP:2052#3   0x0000000117731bce in Ptls6::LsFormatMainLine(Ptls6::lscontext*, Ptls6::lsbreakrecline const*, Ptls6::grchunkext*, Ptls6::lsformatcontext*, int*, Ptls6::CLsLine**, int*, int*) at /Users/albertborges/sd/dev/PTLS/LS/src/LSFORMAT.CPP:2144   0x000000011771b37a in Ptls6::LsCreateLineCore(Ptls6::lscontext*, Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, int, int, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::tslinepenaltyinfo**, Ptls6::CLsLine**) at /Users/albertborges/sd/dev/PTLS/LS/src/LSCRLINEAPI.CPP:218#5   0x000000011771a7d9 in Ptls6::LsCreateLine(Ptls6::lscontext*, Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::CLsLine**) at /Users/albertborges/sd/dev/PTLS/LS/src/LSCRLINE.CPP:68#6   0x000000011827884d in Ptls6::lscontext::CreateLine(Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::CLsLine**) at /Users/albertborges/sd/dev/richedit/src/_ls.h:93#7   0x0000000118275dfa in Ptls6::ols::MeasureLine(unsigned int, int*, int, bool, bool, bool, int*, int*, CBreakRecLine const*) at /Users/albertborges/sd/dev/richedit/src/OLS.CPP:2260#8   0x0000000118211c91 in LS::MeasureLine(CMeasurer&, unsigned int, int*, int, bool, int&, int*, int*, CBreakRecLine const*) at /Users/albertborges/sd/dev/richedit/src/lsmain.cpp:69#9   0x0000000118209c18 in CLine::UpFromCch(CMeasurer&, int, unsigned int, CDispDim*, int*, CBreakRecLine const*) const at /Users/albertborges/sd/dev/richedit/src/line.cpp:466#10   0x00000001181f5c66 in CLayoutLineArray::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const at /Users/albertborges/sd/dev/richedit/src/layout.cpp:1409#11   0x00000001181fcc6b in CLayoutColumn::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const at /Users/albertborges/sd/dev/richedit/src/layout.cpp:3019#12   0x000000011824ec07 in CDisplayTree::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const at /Users/albertborges/sd/dev/richedit/src/_disptree.h:212#13   0x000000011824eaff in CFSREContext::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const at /Users/albertborges/sd/dev/richedit/src/ofs.cpp:2005#14   0x0000000118167fd3 in CDisplayEnginePTS::PointFromTp(CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, CMeasurer*) const at /Users/albertborges/sd/dev/richedit/src/dispengpts.cpp:1355#15   0x000000011816dd5b in CDisplayML::PointFromTp(CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, CMeasurer*) at /Users/albertborges/sd/dev/richedit/src/dispml.cpp:1105#16   0x00000001182b518a in COTxHost::OTxGetBulletRect(int, tagRECT&) const at /Users/albertborges/sd/dev/richedit/src/otxhost.cpp:1758";
   
   NSString* timeProfilerStack = @" 24 Gfx 5.0  GEL::DWriteTypefaceList::LinkNextRun(wchar_t const*, unsigned int, GEL::Font&, unsigned int&) const /Users/albertborges/sd/dev/gfx/gel/dwritefonts.cpp:1757\n23 Gfx 5.0  GEL::DWriteFontLinker::DWriteFontLinker(wchar_t const*, unsigned int, GEL::DWriteTypefaceList const&, GEL::Font const&, unsigned int) /Users/albertborges/sd/dev/gfx/gel/dwritefonts.cpp:1452\n22 Gfx 5.0  GEL::DWriteFontLinker::DWriteFontLinker(wchar_t const*, unsigned int, GEL::DWriteTypefaceList const&, GEL::Font const&, unsigned int) /Users/albertborges/sd/dev/gfx/gel/dwritefonts.cpp:1467\n21 Gfx 4.0  GEL::CreateDWAFontFromGelFont(GEL::ITypefaceList const&, GEL::Font const&, tagLOGFONTW*) /Users/albertborges/sd/dev/gfx/gel/dwritefonts.cpp:90\n20 mso40ui 3.0  Mso::DWriteAssistant::Create(wchar_t const*, bool, bool, bool, unsigned char, int) /Users/albertborges/sd/dev/liblet/dwriteassistant/msoDWrite.cpp:317\n19 mso40ui 3.0  Mso::DWriteAssistant::Font::Font(wchar_t const*, bool, bool, bool, unsigned char, int) /Users/albertborges/sd/dev/liblet/dwriteassistant/msoDWrite.cpp:247\n18 mso40ui 3.0  Mso::DWriteAssistant::Font::Font(wchar_t const*, bool, bool, bool, unsigned char, int) /Users/albertborges/sd/dev/liblet/dwriteassistant/msoDWrite.cpp:289\n17 mso40ui 3.0  Mso::DWriteAssistant::Font::GetDWriteFontFromLogFont(tagLOGFONTW const&) /Users/albertborges/sd/dev/liblet/dwriteassistant/msodwrite_fontcollection.cpp:45\n16 mso40ui 3.0  Mso::DWriteAssistant::FontCollection::GetFontFaceFromLogFont(tagLOGFONTW const&, Mso::TCntPtr<IDWriteFontFace>&) /Users/albertborges/sd/dev/liblet/dwriteassistant/FontCollection.cpp:621\n15 mso40ui 3.0  Mso::DWriteAssistant::FontCollection::GetFontFaceFromLogFontEx(tagLOGFONTW const&, unsigned int, Mso::TCntPtr<IDWriteFontFace>&) /Users/albertborges/sd/dev/liblet/dwriteassistant/FontCollection.cpp:630\n14 mso40ui 3.0  Mso::DWriteAssistant::FontCollection::GetFontFaceFromLogFontEx(tagLOGFONTW const&, unsigned int, Mso::TCntPtr<IDWriteFontFace>&, bool&) /Users/albertborges/sd/dev/liblet/dwriteassistant/FontCollection.cpp:654\n13 mso40ui 3.0  void Mso::Logging::MsoSendStructuredTraceTag<Mso::Logging::StructuredObject<wchar_t const*, true> >(unsigned int, Mso::Logging::Category, Mso::Logging::Severity, wchar_t const*, Mso::Logging::StructuredObject<wchar_t const*, true>&&) /Volumes/Build/builds/devmain/rawproduct/Debug/build/tmp/liblet/target/publicinc/logging/msoLogging.h:118";
   
   NSDateComponents *startDate = [[NSDateComponents alloc] init];
   [startDate setYear:2018];
   [startDate setMonth:2];
   [startDate setDay:26];
   [startDate setHour:22];
   [startDate setMinute:00];
   [startDate setSecond:00];
   
   NSDateComponents *endDate = [[NSDateComponents alloc] init];
   [endDate setYear:2018];
   [endDate setMonth:2];
   [endDate setDay:26];
   [endDate setHour:22];
   [endDate setMinute:00];
   [endDate setSecond:00];
   
   std::vector< ChangeList > changelists = ParseTimeProfilerStack(timeProfilerStack, startDate, endDate);
}


- (void)setRepresentedObject:(id)representedObject {
   [super setRepresentedObject:representedObject];

   // Update the view, if already loaded.
}


@end
