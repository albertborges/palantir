//
//  ParseStackAPI.hpp
//  Palantir
//
//  Created by Albert Borges on 2/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#ifndef ParseStackAPI_hpp
#define ParseStackAPI_hpp

#include <stdio.h>
#import <Cocoa/Cocoa.h>
#include <string>
#include <vector>

enum InputType
{
   XcodeStack,
   TimeProfilerStack
   // TODO FileIO and Watson
};

struct File
{
   std::string filename;
   bool culpable; // Used to determine if this file is the reason why this CL is being marked as questionable for the UI
};

struct ChangeList
{
   int identifier;
   std::vector< File > files;
   std::string author;
};

enum Error
{
   NoCorpConnectivity, // No Internet Connectivity or not connected to CorpNet
   CredentialInitializationNeeded, // Security system: Could not initialize security context: Ticket expired. User not authenticated.
   NoError
};

/*
Sample stackData (NSString*) parameter:
   NSString* xcodeStack = @"#0   0x000000011827e492 in Ptls6::ols::FetchRun(int, int, Ptls6::lsstyle*, wchar_t const**, int*, bool*, Ptls6::lschp*, unsigned short*, Ptls6::lsrun**, int, Ptls6::lsspanqualifierInfo const&, bool&) at /Users/albertborges/sd/dev/richedit/src/OLS.CPP:4198#1   0x000000011828562d in OlsFetchRun(Ptls6::ols*, Ptls6::lsparaclient*, Ptls6::lsspan_struct, int, int, Ptls6::lsstyle*, Ptls6::lsfetchposition, Ptls6::lsfetchresult*) at /Users/albertborges/sd/dev/richedit/src/OLS.CPP:5613#2   0x000000011772b330 in Ptls6::LsQuickFormatting(Ptls6::CLsSubline*, Ptls6::lsformatcontext*, int, int*, int*, int*, int*, int*, int*, Ptls6::lsfetchresult*) at /Users/albertborges/sd/dev/PTLS/LS/src/LSFETCH.CPP:2052#3   0x0000000117731bce in Ptls6::LsFormatMainLine(Ptls6::lscontext*, Ptls6::lsbreakrecline const*, Ptls6::grchunkext*, Ptls6::lsformatcontext*, int*, Ptls6::CLsLine**, int*, int*) at /Users/albertborges/sd/dev/PTLS/LS/src/LSFORMAT.CPP:2144   0x000000011771b37a in Ptls6::LsCreateLineCore(Ptls6::lscontext*, Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, int, int, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::tslinepenaltyinfo**, Ptls6::CLsLine**) at /Users/albertborges/sd/dev/PTLS/LS/src/LSCRLINEAPI.CPP:218#5   0x000000011771a7d9 in Ptls6::LsCreateLine(Ptls6::lscontext*, Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::CLsLine**) at /Users/albertborges/sd/dev/PTLS/LS/src/LSCRLINE.CPP:68#6   0x000000011827884d in Ptls6::lscontext::CreateLine(Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::CLsLine**) at /Users/albertborges/sd/dev/richedit/src/_ls.h:93#7   0x0000000118275dfa in Ptls6::ols::MeasureLine(unsigned int, int*, int, bool, bool, bool, int*, int*, CBreakRecLine const*) at /Users/albertborges/sd/dev/richedit/src/OLS.CPP:2260#8   0x0000000118211c91 in LS::MeasureLine(CMeasurer&, unsigned int, int*, int, bool, int&, int*, int*, CBreakRecLine const*) at /Users/albertborges/sd/dev/richedit/src/lsmain.cpp:69#9   0x0000000118209c18 in CLine::UpFromCch(CMeasurer&, int, unsigned int, CDispDim*, int*, CBreakRecLine const*) const at /Users/albertborges/sd/dev/richedit/src/line.cpp:466#10   0x00000001181f5c66 in CLayoutLineArray::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const at /Users/albertborges/sd/dev/richedit/src/layout.cpp:1409#11   0x00000001181fcc6b in CLayoutColumn::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const at /Users/albertborges/sd/dev/richedit/src/layout.cpp:3019#12   0x000000011824ec07 in CDisplayTree::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const at /Users/albertborges/sd/dev/richedit/src/_disptree.h:212#13   0x000000011824eaff in CFSREContext::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const at /Users/albertborges/sd/dev/richedit/src/ofs.cpp:2005#14   0x0000000118167fd3 in CDisplayEnginePTS::PointFromTp(CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, CMeasurer*) const at /Users/albertborges/sd/dev/richedit/src/dispengpts.cpp:1355#15   0x000000011816dd5b in CDisplayML::PointFromTp(CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, CMeasurer*) at /Users/albertborges/sd/dev/richedit/src/dispml.cpp:1105#16   0x00000001182b518a in COTxHost::OTxGetBulletRect(int, tagRECT&) const at /Users/albertborges/sd/dev/richedit/src/otxhost.cpp:1758";
"
 
 Sample startTime initialization for 2/26/2018 22:00:00:
 NSDateComponents *components = [[NSDateComponents alloc] init];
 [components setYear:2018];
 [components setMonth:2];
 [components setDay:26];
 [components setHour:22];
 [components setMinute:00];
 [components setSecond:00];
 
 Sample endTime initialization for 2/27/2018 22:00:00:
 NSDateComponents *components = [[NSDateComponents alloc] init];
 [components setYear:2018];
 [components setMonth:2];
 [components setDay:27];
 [components setHour:22];
 [components setMinute:00];
 [components setSecond:00];
*/
Error ParseXcodeStack( NSString* stackData, NSDateComponents* startTime, NSDateComponents* endTime, std::vector< ChangeList >& changelists );

/*
 Sample stackData (NSString*) parameter:
 @"
 51 OfficeArt 6.0  Art::TextViewElement::FGetCursorID(Art::View::HitTestInfo const&, Art::Cursor::CursorID&) /Users/albertborges/sd/dev/oart/gvl/textviewelement.cpp:480
 50 OfficeArt 6.0  Art::FMouseOverBullet(Art::View::HitTestInfo const&, Ofc::TReferringPtr<Art::ITextLayout> const&, Ofc::TSharedPtr<Art::View> const&, int&) /Users/albertborges/sd/dev/oart/text/txutils.cpp:478
 49 OfficeArt 6.0  Art::TextLayoutRichEditImpl::GetBulletRect(int, GEL::Rect&) const /Users/albertborges/sd/dev/oart/text/txlayoutre.cpp:2050
 48 OfficeArt 6.0  Art::TextBoxLayoutWrapper::GetBulletRect(int, GEL::Rect&) const /Users/albertborges/sd/dev/oart/text/txboxlayoutwrapper.cpp:987
 47 MicrosoftRichEdit 6.0  non-virtual thunk to COTxHost::OTxGetBulletRect(int, tagRECT&) const /Users/albertborges/sd/dev/richedit/src/otxhost.cpp:0
 46 MicrosoftRichEdit 6.0  COTxHost::OTxGetBulletRect(int, tagRECT&) const /Users/albertborges/sd/dev/richedit/src/otxhost.cpp:1725
 45 MicrosoftRichEdit 6.0  CDisplayML::PointFromTp(CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, CMeasurer*) /Users/albertborges/sd/dev/richedit/src/dispml.cpp:1105
 44 MicrosoftRichEdit 6.0  CDisplayEnginePTS::PointFromTp(CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, CMeasurer*) const /Users/albertborges/sd/dev/richedit/src/dispengpts.cpp:1355
 43 MicrosoftRichEdit 6.0  CFSREContext::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const /Users/albertborges/sd/dev/richedit/src/ofs.cpp:2005
 42 MicrosoftRichEdit 6.0  CDisplayTree::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const /Users/albertborges/sd/dev/richedit/src/_disptree.h:212
 41 MicrosoftRichEdit 6.0  CLayoutColumn::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const /Users/albertborges/sd/dev/richedit/src/layout.cpp:3019
 40 MicrosoftRichEdit 6.0  CLayoutLineArray::PointFromTp(CMeasurer&, CRchTxtPtr const&, RECTUV const*, int, Ptls6::tagLSPOINTUV&, CLinePtr*, unsigned int, CDispDim*, int) const /Users/albertborges/sd/dev/richedit/src/layout.cpp:1409
 39 MicrosoftRichEdit 6.0  CLine::UpFromCch(CMeasurer&, int, unsigned int, CDispDim*, int*, CBreakRecLine const*) const /Users/albertborges/sd/dev/richedit/src/line.cpp:466
 38 MicrosoftRichEdit 6.0  LS::MeasureLine(CMeasurer&, unsigned int, int*, int, bool, int&, int*, int*, CBreakRecLine const*) /Users/albertborges/sd/dev/richedit/src/lsmain.cpp:69
 37 MicrosoftRichEdit 6.0  Ptls6::ols::MeasureLine(unsigned int, int*, int, bool, bool, bool, int*, int*, CBreakRecLine const*) /Users/albertborges/sd/dev/richedit/src/OLS.CPP:2260
 36 MicrosoftRichEdit 6.0  Ptls6::lscontext::CreateLine(Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::CLsLine**) /Users/albertborges/sd/dev/richedit/src/_ls.h:93
 35 MicrosoftPTLS 6.0  Ptls6::LsCreateLine(Ptls6::lscontext*, Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::CLsLine**) /Users/albertborges/sd/dev/PTLS/LS/src/LSCRLINE.CPP:68
 34 MicrosoftPTLS 6.0  Ptls6::LsCreateLineCore(Ptls6::lscontext*, Ptls6::lsparaclient*, Ptls6::lspap const*, int, Ptls6::lslinerestr const*, Ptls6::lsbreakrecline const*, int, int, Ptls6::lsbreakrecline**, Ptls6::lslinfo*, Ptls6::tslinepenaltyinfo**, Ptls6::CLsLine**) /Users/albertborges/sd/dev/PTLS/LS/src/LSCRLINEAPI.CPP:218
 33 MicrosoftPTLS 6.0  Ptls6::LsFormatMainLine(Ptls6::lscontext*, Ptls6::lsbreakrecline const*, Ptls6::grchunkext*, Ptls6::lsformatcontext*, int*, Ptls6::CLsLine**, int*, int*) /Users/albertborges/sd/dev/PTLS/LS/src/LSFORMAT.CPP:214
 32 MicrosoftPTLS 6.0  Ptls6::LsQuickFormatting(Ptls6::CLsSubline*, Ptls6::lsformatcontext*, int, int*, int*, int*, int*, int*, int*, Ptls6::lsfetchresult*) /Users/albertborges/sd/dev/PTLS/LS/src/LSFETCH.CPP:2052
 31 MicrosoftRichEdit 6.0  OlsFetchRun(Ptls6::ols*, Ptls6::lsparaclient*, Ptls6::lsspan_struct, int, int, Ptls6::lsstyle*, Ptls6::lsfetchposition, Ptls6::lsfetchresult*) /Users/albertborges/sd/dev/richedit/src/OLS.CPP:5613
 30 MicrosoftRichEdit 6.0  Ptls6::ols::FetchRun(int, int, Ptls6::lsstyle*, wchar_t const**, int*, bool*, Ptls6::lschp*, unsigned short*, Ptls6::lsrun**, int, Ptls6::lsspanqualifierInfo const&, bool&) /Users/albertborges/sd/dev/richedit/src/OLS.CPP:4612
 29 MicrosoftRichEdit 6.0  Ptls6::ols::GetPlsrun(int, int, short, wchar_t const*, int&, Ptls6::lschp*, wchar_t, bool*, int, int, unsigned char, SpecialBulletRun, bool*) /Users/albertborges/sd/dev/richedit/src/OLS.CPP:1400
 28 MicrosoftRichEdit 6.0  CMeasurerPtr::GetNewTextRunData(CLsrunPtr const&, int, int, wchar_t const*, int&, Ptls6::lschp*, bool*) const /Users/albertborges/sd/dev/richedit/src/measurerptr.cpp:658
 27 OfficeArt 6.0  Art::CLineLayout::OTxGetNewTextRunData(OTx::TextRunReference const&, unsigned short, int, int, wchar_t const*, int&, OTx::NewTextRunData&) /Users/albertborges/sd/dev/oart/text/linelayout.cpp:474
 26 OfficeArt 6.0  Art::CLineLayout::FetchRun(int, wchar_t const*, int&, int, OTx::NewTextRunData&, Art::CLsrunBase&) /Users/albertborges/sd/dev/oart/text/linelayout.cpp:2413
 25 OfficeArt 5.0  Art::SetupRunFont(Art::DeviceHandle const&, Art::CLsrunBase&, wchar_t const*, int&) /Users/albertborges/sd/dev/oart/text/linelayout.cpp:140
 24 Gfx 5.0  GEL::DWriteTypefaceList::LinkNextRun(wchar_t const*, unsigned int, GEL::Font&, unsigned int&) const /Users/albertborges/sd/dev/gfx/gel/dwritefonts.cpp:1757
 23 Gfx 5.0  GEL::DWriteFontLinker::DWriteFontLinker(wchar_t const*, unsigned int, GEL::DWriteTypefaceList const&, GEL::Font const&, unsigned int) /Users/albertborges/sd/dev/gfx/gel/dwritefonts.cpp:1452
 22 Gfx 5.0  GEL::DWriteFontLinker::DWriteFontLinker(wchar_t const*, unsigned int, GEL::DWriteTypefaceList const&, GEL::Font const&, unsigned int) /Users/albertborges/sd/dev/gfx/gel/dwritefonts.cpp:1467
 21 Gfx 4.0  GEL::CreateDWAFontFromGelFont(GEL::ITypefaceList const&, GEL::Font const&, tagLOGFONTW*) /Users/albertborges/sd/dev/gfx/gel/dwritefonts.cpp:90
 20 mso40ui 3.0  Mso::DWriteAssistant::Create(wchar_t const*, bool, bool, bool, unsigned char, int) /Users/albertborges/sd/dev/liblet/dwriteassistant/msoDWrite.cpp:317
 19 mso40ui 3.0  Mso::DWriteAssistant::Font::Font(wchar_t const*, bool, bool, bool, unsigned char, int) /Users/albertborges/sd/dev/liblet/dwriteassistant/msoDWrite.cpp:247
 18 mso40ui 3.0  Mso::DWriteAssistant::Font::Font(wchar_t const*, bool, bool, bool, unsigned char, int) /Users/albertborges/sd/dev/liblet/dwriteassistant/msoDWrite.cpp:289
 17 mso40ui 3.0  Mso::DWriteAssistant::Font::GetDWriteFontFromLogFont(tagLOGFONTW const&) /Users/albertborges/sd/dev/liblet/dwriteassistant/msodwrite_fontcollection.cpp:45
 16 mso40ui 3.0  Mso::DWriteAssistant::FontCollection::GetFontFaceFromLogFont(tagLOGFONTW const&, Mso::TCntPtr<IDWriteFontFace>&) /Users/albertborges/sd/dev/liblet/dwriteassistant/FontCollection.cpp:621
 15 mso40ui 3.0  Mso::DWriteAssistant::FontCollection::GetFontFaceFromLogFontEx(tagLOGFONTW const&, unsigned int, Mso::TCntPtr<IDWriteFontFace>&) /Users/albertborges/sd/dev/liblet/dwriteassistant/FontCollection.cpp:630
 14 mso40ui 3.0  Mso::DWriteAssistant::FontCollection::GetFontFaceFromLogFontEx(tagLOGFONTW const&, unsigned int, Mso::TCntPtr<IDWriteFontFace>&, bool&) /Users/albertborges/sd/dev/liblet/dwriteassistant/FontCollection.cpp:654
 13 mso40ui 3.0  void Mso::Logging::MsoSendStructuredTraceTag<Mso::Logging::StructuredObject<wchar_t const*, true> >(unsigned int, Mso::Logging::Category, Mso::Logging::Severity, wchar_t const*, Mso::Logging::StructuredObject<wchar_t const*, true>&&) /Volumes/Build/builds/devmain/rawproduct/Debug/build/tmp/liblet/target/publicinc/logging/msoLogging.h:118
 "
 
 Sample startTime initialization for 2/26/2018 22:00:00:
 NSDateComponents *components = [[NSDateComponents alloc] init];
 [components setYear:2018];
 [components setMonth:2];
 [components setDay:26];
 [components setHour:22];
 [components setMinute:00];
 [components setSecond:00];
 
 Sample endTime initialization for 2/27/2018 22:00:00:
 NSDateComponents *components = [[NSDateComponents alloc] init];
 [components setYear:2018];
 [components setMonth:2];
 [components setDay:27];
 [components setHour:22];
 [components setMinute:00];
 [components setSecond:00];
 */
 Error ParseTimeProfilerStack( NSString* stackData, NSDateComponents* start, NSDateComponents* end, std::vector< ChangeList >& changelists );

#endif /* ParseStackAPI_hpp */
