﻿// CodeGear C++Builder
// Copyright (c) 1995, 2024 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'GBE.Grass.pas' rev: 36.00 (Windows)

#ifndef GBE_GrassHPP
#define GBE_GrassHPP

#pragma delphiheader begin
#pragma option push
#if defined(__BORLANDC__) && !defined(__clang__)
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#endif
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <System.SysUtils.hpp>
#include <System.Classes.hpp>
#include <System.RTLConsts.hpp>
#include <FMX.Types.hpp>
#include <FMX.Controls3D.hpp>
#include <FMX.Objects3D.hpp>
#include <FMX.Graphics.hpp>
#include <System.UITypes.hpp>
#include <FMX.Materials.hpp>
#include <FMX.Types3D.hpp>
#include <System.Types.hpp>
#include <System.Math.Vectors.hpp>
#include <FMX.MaterialSources.hpp>
#include <System.Threading.hpp>

//-- user supplied -----------------------------------------------------------

namespace Gbe
{
namespace Grass
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS TGBEGrass;
//-- type declarations -------------------------------------------------------
class PASCALIMPLEMENTATION TGBEGrass : public Fmx::Objects3d::TMesh
{
	typedef Fmx::Objects3d::TMesh inherited;
	
private:
	bool fWind;
	float fTemps;
	
protected:
	virtual void __fastcall Render();
	
public:
	__fastcall virtual TGBEGrass(System::Classes::TComponent* AOwner);
	__fastcall virtual ~TGBEGrass();
	void __fastcall GenerateGrass();
	
__published:
	__property Locked = {default=0};
	__property HitTest = {default=0};
	__property float Temps = {read=fTemps, write=fTemps};
	__property bool Wind = {read=fWind, write=fWind, nodefault};
	__property ZWrite = {default=0};
	__property Visible = {default=1};
};


//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE void __fastcall Register(void);
}	/* namespace Grass */
}	/* namespace Gbe */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_GBE_GRASS)
using namespace Gbe::Grass;
#endif
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_GBE)
using namespace Gbe;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// GBE_GrassHPP
