﻿// CodeGear C++Builder
// Copyright (c) 1995, 2024 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'GLS.Coordinates.pas' rev: 36.00 (Windows)

#ifndef GLS_CoordinatesHPP
#define GLS_CoordinatesHPP

#pragma delphiheader begin
#pragma option push
#if defined(__BORLANDC__) && !defined(__clang__)
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#endif
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <System.Math.hpp>
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <Stage.VectorGeometry.hpp>
#include <GLS.BaseClasses.hpp>
#include <Stage.VectorTypes.hpp>

//-- user supplied -----------------------------------------------------------

namespace Gls
{
namespace Coordinates
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS TGLCustomCoordinates;
class DELPHICLASS TGLCoordinates2;
class DELPHICLASS TGLCoordinates3;
class DELPHICLASS TGLCoordinates4;
__interface DELPHIINTERFACE IGLCoordinatesUpdateAble;
typedef System::DelphiInterface<IGLCoordinatesUpdateAble> _di_IGLCoordinatesUpdateAble;
class DELPHICLASS TGLCoordinatesUpdateAbleComponent;
//-- type declarations -------------------------------------------------------
enum DECLSPEC_DENUM TGLCoordinatesStyle : unsigned char { csPoint2D, csPoint, csVector, csUnknown };

class PASCALIMPLEMENTATION TGLCustomCoordinates : public Gls::Baseclasses::TGLUpdateAbleObject
{
	typedef Gls::Baseclasses::TGLUpdateAbleObject inherited;
	
public:
	float operator[](const int AIndex) { return this->Coordinate[AIndex]; }
	
private:
	Stage::Vectortypes::TGLVector FCoords;
	TGLCoordinatesStyle FStyle;
	Stage::Vectortypes::PGLVector FPDefaultCoords;
	void __fastcall SetAsPoint2D(const Stage::Vectortypes::TVector2f &Value);
	void __fastcall SetAsVector(const Stage::Vectortypes::TGLVector &Value);
	void __fastcall SetAsAffineVector(const Stage::Vectorgeometry::TAffineVector &Value);
	Stage::Vectorgeometry::TAffineVector __fastcall GetAsAffineVector();
	Stage::Vectortypes::TVector2f __fastcall GetAsPoint2D();
	System::UnicodeString __fastcall GetAsString();
	float __fastcall GetCoordinate(const int AIndex);
	void __fastcall SetCoordinate(const int AIndex, const float AValue);
	float __fastcall GetDirectCoordinate(const int Index);
	void __fastcall SetDirectCoordinate(const int Index, const float AValue);
	
protected:
	void __fastcall SetDirectVector(const Stage::Vectortypes::TGLVector &V);
	virtual void __fastcall DefineProperties(System::Classes::TFiler* Filer);
	void __fastcall ReadData(System::Classes::TStream* Stream);
	void __fastcall WriteData(System::Classes::TStream* Stream);
	
public:
	__fastcall TGLCustomCoordinates(System::Classes::TPersistent* AOwner, const Stage::Vectortypes::TGLVector &AValue, const TGLCoordinatesStyle AStyle);
	__fastcall virtual ~TGLCustomCoordinates();
	virtual void __fastcall Assign(System::Classes::TPersistent* Source);
	void __fastcall WriteToFiler(System::Classes::TWriter* Writer);
	void __fastcall ReadFromFiler(System::Classes::TReader* Reader);
	void __fastcall Initialize(const Stage::Vectortypes::TGLVector &Value);
	virtual void __fastcall NotifyChange(System::TObject* Sender);
	__property TGLCoordinatesStyle Style = {read=FStyle, write=FStyle, nodefault};
	void __fastcall Translate(const Stage::Vectortypes::TGLVector &TranslationVector)/* overload */;
	void __fastcall Translate(const Stage::Vectorgeometry::TAffineVector &TranslationVector)/* overload */;
	void __fastcall AddScaledVector(const float Factor, const Stage::Vectortypes::TGLVector &TranslationVector)/* overload */;
	void __fastcall AddScaledVector(const float Factor, const Stage::Vectorgeometry::TAffineVector &TranslationVector)/* overload */;
	void __fastcall Rotate(const Stage::Vectorgeometry::TAffineVector &AnAxis, float AnAngle)/* overload */;
	void __fastcall Rotate(const Stage::Vectortypes::TGLVector &AnAxis, float AnAngle)/* overload */;
	void __fastcall Normalize();
	void __fastcall Invert();
	void __fastcall Scale(float Factor);
	float __fastcall VectorLength();
	float __fastcall VectorNorm();
	float __fastcall MaxXYZ();
	HIDESBASE bool __fastcall Equals(const Stage::Vectortypes::TGLVector &AVector);
	void __fastcall SetVector(const float X, const float Y, float Z = 0.000000E+00f)/* overload */;
	void __fastcall SetVector(const float X, const float Y, const float Z, const float W)/* overload */;
	void __fastcall SetVector(const Stage::Vectorgeometry::TAffineVector &V)/* overload */;
	void __fastcall SetVector(const Stage::Vectortypes::TGLVector &V)/* overload */;
	void __fastcall SetPoint(const float X, const float Y, const float Z)/* overload */;
	void __fastcall SetPoint(const Stage::Vectorgeometry::TAffineVector &V)/* overload */;
	void __fastcall SetPoint(const Stage::Vectortypes::TGLVector &V)/* overload */;
	void __fastcall SetPoint2D(const float X, const float Y)/* overload */;
	void __fastcall SetPoint2D(const Stage::Vectorgeometry::TAffineVector &Vector)/* overload */;
	void __fastcall SetPoint2D(const Stage::Vectortypes::TGLVector &Vector)/* overload */;
	void __fastcall SetPoint2D(const Stage::Vectortypes::TVector2f &Vector)/* overload */;
	void __fastcall SetToZero();
	System::PSingle __fastcall AsAddress();
	__property Stage::Vectortypes::TGLVector AsVector = {read=FCoords, write=SetAsVector};
	__property Stage::Vectorgeometry::TAffineVector AsAffineVector = {read=GetAsAffineVector, write=SetAsAffineVector};
	__property Stage::Vectortypes::TVector2f AsPoint2D = {read=GetAsPoint2D, write=SetAsPoint2D};
	__property float X = {read=GetCoordinate, write=SetCoordinate, index=0};
	__property float Y = {read=GetCoordinate, write=SetCoordinate, index=1};
	__property float Z = {read=GetCoordinate, write=SetCoordinate, index=2};
	__property float W = {read=GetCoordinate, write=SetCoordinate, index=3};
	__property float Coordinate[const int AIndex] = {read=GetCoordinate, write=SetCoordinate/*, default*/};
	__property System::UnicodeString AsString = {read=GetAsString};
	__property Stage::Vectortypes::TGLVector DirectVector = {read=FCoords, write=SetDirectVector};
	__property float DirectX = {read=GetDirectCoordinate, write=SetDirectCoordinate, index=0};
	__property float DirectY = {read=GetDirectCoordinate, write=SetDirectCoordinate, index=1};
	__property float DirectZ = {read=GetDirectCoordinate, write=SetDirectCoordinate, index=2};
	__property float DirectW = {read=GetDirectCoordinate, write=SetDirectCoordinate, index=3};
public:
	/* TGLUpdateAbleObject.Create */ inline __fastcall virtual TGLCustomCoordinates(System::Classes::TPersistent* AOwner) : Gls::Baseclasses::TGLUpdateAbleObject(AOwner) { }
	
};


class PASCALIMPLEMENTATION TGLCoordinates2 : public TGLCustomCoordinates
{
	typedef TGLCustomCoordinates inherited;
	
__published:
	__property X = {stored=false, index=0, default=0};
	__property Y = {stored=false, index=1, default=0};
public:
	/* TGLCustomCoordinates.CreateInitialized */ inline __fastcall TGLCoordinates2(System::Classes::TPersistent* AOwner, const Stage::Vectortypes::TGLVector &AValue, const TGLCoordinatesStyle AStyle) : TGLCustomCoordinates(AOwner, AValue, AStyle) { }
	/* TGLCustomCoordinates.Destroy */ inline __fastcall virtual ~TGLCoordinates2() { }
	
public:
	/* TGLUpdateAbleObject.Create */ inline __fastcall virtual TGLCoordinates2(System::Classes::TPersistent* AOwner) : TGLCustomCoordinates(AOwner) { }
	
};


class PASCALIMPLEMENTATION TGLCoordinates3 : public TGLCustomCoordinates
{
	typedef TGLCustomCoordinates inherited;
	
__published:
	__property X = {stored=false, index=0, default=0};
	__property Y = {stored=false, index=1, default=0};
	__property Z = {stored=false, index=2, default=0};
public:
	/* TGLCustomCoordinates.CreateInitialized */ inline __fastcall TGLCoordinates3(System::Classes::TPersistent* AOwner, const Stage::Vectortypes::TGLVector &AValue, const TGLCoordinatesStyle AStyle) : TGLCustomCoordinates(AOwner, AValue, AStyle) { }
	/* TGLCustomCoordinates.Destroy */ inline __fastcall virtual ~TGLCoordinates3() { }
	
public:
	/* TGLUpdateAbleObject.Create */ inline __fastcall virtual TGLCoordinates3(System::Classes::TPersistent* AOwner) : TGLCustomCoordinates(AOwner) { }
	
};


class PASCALIMPLEMENTATION TGLCoordinates4 : public TGLCustomCoordinates
{
	typedef TGLCustomCoordinates inherited;
	
__published:
	__property X = {stored=false, index=0, default=0};
	__property Y = {stored=false, index=1, default=0};
	__property Z = {stored=false, index=2, default=0};
	__property W = {stored=false, index=3, default=0};
public:
	/* TGLCustomCoordinates.CreateInitialized */ inline __fastcall TGLCoordinates4(System::Classes::TPersistent* AOwner, const Stage::Vectortypes::TGLVector &AValue, const TGLCoordinatesStyle AStyle) : TGLCustomCoordinates(AOwner, AValue, AStyle) { }
	/* TGLCustomCoordinates.Destroy */ inline __fastcall virtual ~TGLCoordinates4() { }
	
public:
	/* TGLUpdateAbleObject.Create */ inline __fastcall virtual TGLCoordinates4(System::Classes::TPersistent* AOwner) : TGLCustomCoordinates(AOwner) { }
	
};


typedef TGLCoordinates3 TGLCoordinates;

__interface  INTERFACE_UUID("{ACB98D20-8905-43A7-AFA5-225CF5FA6FF5}") IGLCoordinatesUpdateAble  : public System::IInterface 
{
	virtual void __fastcall CoordinateChanged(TGLCustomCoordinates* Sender) = 0 ;
};

class PASCALIMPLEMENTATION TGLCoordinatesUpdateAbleComponent : public Gls::Baseclasses::TGLUpdateAbleComponent
{
	typedef Gls::Baseclasses::TGLUpdateAbleComponent inherited;
	
public:
	virtual void __fastcall CoordinateChanged(TGLCustomCoordinates* Sender) = 0 ;
public:
	/* TComponent.Create */ inline __fastcall virtual TGLCoordinatesUpdateAbleComponent(System::Classes::TComponent* AOwner) : Gls::Baseclasses::TGLUpdateAbleComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TGLCoordinatesUpdateAbleComponent() { }
	
private:
	void *__IGLCoordinatesUpdateAble;	// IGLCoordinatesUpdateAble 
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	// {ACB98D20-8905-43A7-AFA5-225CF5FA6FF5}
	operator _di_IGLCoordinatesUpdateAble()
	{
		_di_IGLCoordinatesUpdateAble intf;
		this->GetInterface(intf);
		return intf;
	}
	#else
	operator IGLCoordinatesUpdateAble*(void) { return (IGLCoordinatesUpdateAble*)&__IGLCoordinatesUpdateAble; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE bool VUseDefaultCoordinateSets;
extern DELPHI_PACKAGE void __fastcall Cylindrical_Cartesian(const float r, const float theta, const float z1, float &x, float &y, float &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall Cylindrical_Cartesian(const double r, const double theta, const double z1, double &x, double &y, double &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall Cylindrical_Cartesian(const float r, const float theta, const float z1, float &x, float &y, float &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall Cylindrical_Cartesian(const double r, const double theta, const double z1, double &x, double &y, double &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall Cartesian_Cylindrical(const float x, const float y, const float z1, float &r, float &theta, float &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall Cartesian_Cylindrical(const double x, const double y, const double z1, double &r, double &theta, double &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall Spherical_Cartesian(const float r, const float theta, const float phi, float &x, float &y, float &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall Spherical_Cartesian(const double r, const double theta, const double phi, double &x, double &y, double &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall Spherical_Cartesian(const float r, const float theta, const float phi, float &x, float &y, float &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall Spherical_Cartesian(const double r, const double theta, const double phi, double &x, double &y, double &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall Cartesian_Spherical(const float x, const float y, const float z, float &r, float &theta, float &phi)/* overload */;
extern DELPHI_PACKAGE void __fastcall Cartesian_Spherical(const Stage::Vectorgeometry::TAffineVector &v, float &r, float &theta, float &phi)/* overload */;
extern DELPHI_PACKAGE void __fastcall Cartesian_Spherical(const double x, const double y, const double z, double &r, double &theta, double &phi)/* overload */;
extern DELPHI_PACKAGE void __fastcall ProlateSpheroidal_Cartesian(const float xi, const float eta, const float phi, const float a, float &x, float &y, float &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall ProlateSpheroidal_Cartesian(const double xi, const double eta, const double phi, const double a, double &x, double &y, double &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall ProlateSpheroidal_Cartesian(const float xi, const float eta, const float phi, const float a, float &x, float &y, float &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall ProlateSpheroidal_Cartesian(const double xi, const double eta, const double phi, const double a, double &x, double &y, double &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall OblateSpheroidal_Cartesian(const float xi, const float eta, const float phi, const float a, float &x, float &y, float &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall OblateSpheroidal_Cartesian(const double xi, const double eta, const double phi, const double a, double &x, double &y, double &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall OblateSpheroidal_Cartesian(const float xi, const float eta, const float phi, const float a, float &x, float &y, float &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall OblateSpheroidal_Cartesian(const double xi, const double eta, const double phi, const double a, double &x, double &y, double &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall BipolarCylindrical_Cartesian(const float u, const float v, const float z1, const float a, float &x, float &y, float &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall BipolarCylindrical_Cartesian(const double u, const double v, const double z1, const double a, double &x, double &y, double &z)/* overload */;
extern DELPHI_PACKAGE void __fastcall BipolarCylindrical_Cartesian(const float u, const float v, const float z1, const float a, float &x, float &y, float &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE void __fastcall BipolarCylindrical_Cartesian(const double u, const double v, const double z1, const double a, double &x, double &y, double &z, int &ierr)/* overload */;
extern DELPHI_PACKAGE bool __fastcall BarycentricCoordinates(const Stage::Vectorgeometry::TAffineVector &V1, const Stage::Vectorgeometry::TAffineVector &V2, const Stage::Vectorgeometry::TAffineVector &V3, const Stage::Vectorgeometry::TAffineVector &p, float &u, float &V);
}	/* namespace Coordinates */
}	/* namespace Gls */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_GLS_COORDINATES)
using namespace Gls::Coordinates;
#endif
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_GLS)
using namespace Gls;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// GLS_CoordinatesHPP
