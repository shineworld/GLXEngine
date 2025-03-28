﻿// CodeGear C++Builder
// Copyright (c) 1995, 2024 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'GLS.FileSTL.pas' rev: 36.00 (Windows)

#ifndef GLS_FileSTLHPP
#define GLS_FileSTLHPP

#pragma delphiheader begin
#pragma option push
#if defined(__BORLANDC__) && !defined(__clang__)
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#endif
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <GLS.ApplicationFileIO.hpp>
#include <Stage.VectorTypes.hpp>
#include <Stage.VectorGeometry.hpp>
#include <GLS.VectorLists.hpp>
#include <GLS.VectorFileObjects.hpp>
#include <Stage.Utils.hpp>
#include <GLS.BaseClasses.hpp>

//-- user supplied -----------------------------------------------------------

namespace Gls
{
namespace Filestl
{
//-- forward type declarations -----------------------------------------------
struct TSTLHeader;
struct TSTLFace;
class DELPHICLASS TGLSTLVectorFile;
//-- type declarations -------------------------------------------------------
#pragma pack(push,1)
struct DECLSPEC_DRECORD TSTLHeader
{
public:
	System::StaticArray<System::Byte, 80> dummy;
	System::LongInt nbFaces;
};
#pragma pack(pop)


typedef Stage::Vectortypes::TVector3f TSTLVertex;

#pragma pack(push,1)
struct DECLSPEC_DRECORD TSTLFace
{
public:
	TSTLVertex normal;
	TSTLVertex v1;
	TSTLVertex v2;
	TSTLVertex v3;
	System::StaticArray<System::Byte, 2> padding;
};
#pragma pack(pop)


class PASCALIMPLEMENTATION TGLSTLVectorFile : public Gls::Vectorfileobjects::TGLVectorFile
{
	typedef Gls::Vectorfileobjects::TGLVectorFile inherited;
	
public:
	__classmethod virtual Gls::Applicationfileio::TGLDataFileCapabilities __fastcall Capabilities();
	virtual void __fastcall LoadFromStream(System::Classes::TStream* aStream);
	virtual void __fastcall SaveToStream(System::Classes::TStream* aStream);
public:
	/* TGLVectorFile.Create */ inline __fastcall virtual TGLSTLVectorFile(System::Classes::TPersistent* AOwner) : Gls::Vectorfileobjects::TGLVectorFile(AOwner) { }
	
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TGLSTLVectorFile() { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE bool STLUseEmbeddedColors;
}	/* namespace Filestl */
}	/* namespace Gls */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_GLS_FILESTL)
using namespace Gls::Filestl;
#endif
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_GLS)
using namespace Gls;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// GLS_FileSTLHPP
