//
// The graphics engine GLXEngine. The unit of GXScene for Delphi
//
unit GXS.GeomObjects;

(*
  Geometric objects:
   - TgxTetrahedron, TgxOctahedron, TgxHexahedron, TgxDodecahedron, TgxIcosahedron;
   - TgxDisk, TgxCylinderBase, TgxCone, TgxCylinder, TgxCapsule, TgxAnnulus,
     TgxTorus, TgxArrowLine, TgxArrowArc, TgxPolygon, TgxFrustum;
   - TgxTeapot;
*)

interface

{$I Stage.Defines.inc}
uses
  Winapi.OpenGL,
  Winapi.OpenGLext,
  System.Math,
  System.Classes,

  GXS.Scene,
  GXS.State,
  GXS.PersistentClasses,
  Stage.VectorTypes,
  GXS.Silhouette,

  Stage.VectorGeometry,
  Stage.Polynomials,
  GXS.VectorFileObjects,
  Stage.PipelineTransform,
  GXS.Material,
  GXS.Texture,
  GXS.GeometryBB,


  GXS.Context,
  GXS.Objects,
  GXS.Mesh,
  GXS.RenderContextInfo;

type
//-------------------- TgxBaseMesh Objects -----------------------
(* The tetrahedron has no texture coordinates defined, ie. without using
    a texture generation mode, no texture will be mapped. *)
  TgxTetrahedron = class(TgxBaseMesh)
  public
    procedure BuildList(var rci: TgxRenderContextInfo); override;
  end;

  (* The octahedron has no texture coordinates defined, ie. without using
    a texture generation mode, no texture will be mapped. *)
  TgxOctahedron = class(TgxBaseMesh)
  public
    procedure BuildList(var rci: TgxRenderContextInfo); override;
  end;

  (* The hexahedron has no texture coordinates defined, ie. without using
    a texture generation mode, no texture will be mapped. *)
  TgxHexahedron = class(TgxBaseMesh)
  public
    procedure BuildList(var rci: TgxRenderContextInfo); override;
  end;

  (* The dodecahedron has no texture coordinates defined, ie. without using
    a texture generation mode, no texture will be mapped. *)
  TgxDodecahedron = class(TgxBaseMesh)
  public
    procedure BuildList(var rci: TgxRenderContextInfo); override;
  end;

  (* The icosahedron has no texture coordinates defined, ie. without using
    a texture generation mode, no texture will be mapped. *)
  TgxIcosahedron = class(TgxBaseMesh)
  public
    procedure BuildList(var rci: TgxRenderContextInfo); override;
  end;
//--------------------------- TGLQuadric Objects -------------------
  (* A Disk object.  The disk may not be complete, it can have a hole (controled by the
    InnerRadius property) and can only be a slice (controled by the StartAngle
    and SweepAngle properties). *)
  TgxDisk = class(TgxQuadricObject)
  private
    FStartAngle, FSweepAngle, FOuterRadius, FInnerRadius: Single;
    FSlices, FLoops : Integer;
    procedure SetOuterRadius(const aValue: Single);
    procedure SetInnerRadius(const aValue: Single);
    procedure SetSlices(aValue: Integer);
    procedure SetLoops(aValue: Integer);
    procedure SetStartAngle(const aValue: Single);
    procedure SetSweepAngle(const aValue: Single);
  public
    constructor Create(AOwner: TComponent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    procedure Assign(Source: TPersistent); override;
    function AxisAlignedDimensionsUnscaled: TVector4f; override;
    function RayCastIntersect(const rayStart, rayVector: TVector4f;
      intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil)
      : Boolean; override;
  published
    // Allows defining a "hole" in the disk.
    property InnerRadius: Single read FInnerRadius write SetInnerRadius;
    // Number of radial mesh subdivisions.
    property Loops: Integer read FLoops write SetLoops default 2;
    (* Outer radius for the disk.
      If you leave InnerRadius at 0, this is the disk radius. *)
    property OuterRadius: Single read FOuterRadius write SetOuterRadius;
    (* Number of mesh slices.
      For instance, if Slices=6, your disk will look like an hexagon.*)
    property Slices: Integer read FSlices write SetSlices default 16;
    property StartAngle: Single read FStartAngle write SetStartAngle;
    property SweepAngle: Single read FSweepAngle write SetSweepAngle;
  end;

  (* Base class to cylinder-like objects.
    Introduces the basic cylinder description properties.
    Be aware teh default slices and stacks make up for a high-poly cylinder,
    unless you're after high-quality lighting it is recommended to reduce the
    Stacks property to 1. *)
  TgxCylinderBase = class(TgxQuadricObject)
  private
    FBottomRadius: Single;
    FSlices, FStacks, FLoops: GLint;
    FHeight: Single;
  protected
    procedure SetBottomRadius(const aValue: Single);
    procedure SetHeight(const aValue: Single);
    procedure SetSlices(aValue: GLint);
    procedure SetStacks(aValue: GLint);
    procedure SetLoops(aValue: GLint);
    function GetTopRadius: Single; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;
    function GenerateSilhouette(const silhouetteParameters
      : TgxSilhouetteParameters): TgxSilhouette; override;
  published
    property BottomRadius: Single read FBottomRadius write SetBottomRadius;
    property Height: Single read FHeight write SetHeight;
    property Slices: GLint read FSlices write SetSlices default 16;
    property Stacks: GLint read FStacks write SetStacks default 4;
    // Number of concentric rings for top/bottom disk(s).
    property Loops: GLint read FLoops write SetLoops default 1;
  end;

  TgxConePart = (coSides, coBottom);
  TgxConeParts = set of TgxConePart;

  // A cone object
  TgxCone = class(TgxCylinderBase)
  private
    FParts: TgxConeParts;
  protected
    procedure SetParts(aValue: TgxConeParts);
    function GetTopRadius: Single; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    function AxisAlignedDimensionsUnscaled: TVector4f; override;
    function RayCastIntersect(const rayStart, rayVector: TVector4f;
      intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil)
      : Boolean; override;
  published
    property Parts: TgxConeParts read FParts write SetParts
      default [coSides, coBottom];
  end;

  TgxCylinderPart = (cySides, cyBottom, cyTop);
  TgxCylinderParts = set of TgxCylinderPart;

  TgxCylinderAlignment = (caCenter, caTop, caBottom);

  // Cylinder object, can also be used to make truncated cones
  TgxCylinder = class(TgxCylinderBase)
  private
    FParts: TgxCylinderParts;
    FTopRadius: Single;
    FAlignment: TgxCylinderAlignment;
  protected
    procedure SetTopRadius(const aValue: Single);
    procedure SetParts(aValue: TgxCylinderParts);
    procedure SetAlignment(val: TgxCylinderAlignment);
    function GetTopRadius: Single; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    function AxisAlignedDimensionsUnscaled: TVector4f; override;
    function RayCastIntersect(const rayStart, rayVector: TVector4f;
      intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil)
      : Boolean; override;
    procedure Align(const startPoint, endPoint: TVector4f); overload;
    procedure Align(const startObj, endObj: TgxBaseSceneObject); overload;
    procedure Align(const startPoint, endPoint: TAffineVector); overload;
  published
    property TopRadius: Single read FTopRadius write SetTopRadius;
    property Parts: TgxCylinderParts read FParts write SetParts
      default [cySides, cyBottom, cyTop];
    property Alignment: TgxCylinderAlignment read FAlignment write SetAlignment
      default caCenter;
  end;

  // Capsule object, can also be used to make truncated cones
  TgxCapsule = class(TgxSceneObject)
  private
    FParts: TgxCylinderParts;
    FRadius: Single;
    FSlices: Integer;
    FStacks: Integer;
    FHeight: Single;
    FAlignment: TgxCylinderAlignment;
  protected
    procedure SetHeight(const aValue: Single);
    procedure SetRadius(const aValue: Single);
    procedure SetSlices(const aValue: integer);
    procedure SetStacks(const aValue: integer);
    procedure SetParts(aValue: TgxCylinderParts);
    procedure SetAlignment(val: TgxCylinderAlignment);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    function AxisAlignedDimensionsUnscaled: TVector4f; override;
    function RayCastIntersect(const rayStart, rayVector: TVector4f;
      intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil)
      : Boolean; override;
    procedure Align(const startPoint, endPoint: TVector4f); overload;
    procedure Align(const startObj, endObj: TgxBaseSceneObject); overload;
    procedure Align(const startPoint, endPoint: TAffineVector); overload;
  published
    property Height: Single read FHeight write SetHeight;
    property Slices: GLint read FSlices write SetSlices;
    property Stacks: GLint read FStacks write SetStacks;
    property Radius: Single read FRadius write SetRadius;
    property Parts: TgxCylinderParts read FParts write SetParts
      default [cySides, cyBottom, cyTop];
    property Alignment: TgxCylinderAlignment read FAlignment write SetAlignment
      default caCenter;
  end;

  TgxAnnulusPart = (anInnerSides, anOuterSides, anBottom, anTop);
  TgxAnnulusParts = set of TgxAnnulusPart;

  // An annulus is a cylinder that can be made hollow (pipe-like).
  TgxAnnulus = class(TgxCylinderBase)
  private
    FParts: TgxAnnulusParts;
    FBottomInnerRadius: Single;
    FTopInnerRadius: Single;
    FTopRadius: Single;
  protected
    procedure SetTopRadius(const aValue: Single);
    procedure SetTopInnerRadius(const aValue: Single);
    procedure SetBottomInnerRadius(const aValue: Single);
    procedure SetParts(aValue: TgxAnnulusParts);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    function AxisAlignedDimensionsUnscaled: TVector4f; override;
    function RayCastIntersect(const rayStart, rayVector: TVector4f;
      intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil)
      : Boolean; override;
  published
    property BottomInnerRadius: Single read FBottomInnerRadius
      write SetBottomInnerRadius;
    property TopInnerRadius: Single read FTopInnerRadius
      write SetTopInnerRadius;
    property TopRadius: Single read FTopRadius write SetTopRadius;
    property Parts: TgxAnnulusParts read FParts write SetParts
      default [anInnerSides, anOuterSides, anBottom, anTop];
  end;

  TgxTorusPart = (toSides, toStartDisk, toStopDisk);
  TgxTorusParts = set of TgxTorusPart;

  // A Torus object
  TgxTorus = class(TgxSceneObject)
  private
    FParts: TgxTorusParts;
    FRings, FSides: Cardinal;
    FStartAngle, FStopAngle: Single;
    FMinorRadius, FMajorRadius: Single;
    FMesh: array of array of TVertexRec;
  protected
    procedure SetMajorRadius(const aValue: Single);
    procedure SetMinorRadius(const aValue: Single);
    procedure SetRings(aValue: Cardinal);
    procedure SetSides(aValue: Cardinal);
    procedure SetStartAngle(const aValue: Single);
    procedure SetStopAngle(const aValue: Single);
    procedure SetParts(aValue: TgxTorusParts);
  public
    constructor Create(AOwner: TComponent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    function AxisAlignedDimensionsUnscaled: TVector4f; override;
    function RayCastIntersect(const rayStart, rayVector: TVector4f;
      intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil): Boolean; override;
  published
    property MajorRadius: Single read FMajorRadius write SetMajorRadius;
    property MinorRadius: Single read FMinorRadius write SetMinorRadius;
    property Rings: Cardinal read FRings write SetRings default 25;
    property Sides: Cardinal read FSides write SetSides default 15;
    property StartAngle: Single read FStartAngle write SetStartAngle;
    property StopAngle: Single read FStopAngle write SetStopAngle;
    property Parts: TgxTorusParts read FParts write SetParts default [toSides];
  end;

  TgxArrowLinePart = (alLine, alTopArrow, alBottomArrow);
  TgxArrowLineParts = set of TgxArrowLinePart;

  //Arrow Head Stacking Style
  TgxArrowHeadStyle = (ahssStacked, ahssCentered, ahssIncluded);

  (* Draws an arrowhead (cylinder + cone).
    The arrow head is a cone that shares the attributes of the cylinder
    (ie stacks/slices, materials etc). Seems to work ok.
    This is useful for displaying a vector based field (eg velocity) or
    other arrows that might be required.
    By default the bottom arrow is off *)
  TgxArrowLine = class(TgxCylinderBase)
  private
    FParts: TgxArrowLineParts;
    FTopRadius: Single;
    fTopArrowHeadHeight: Single;
    fTopArrowHeadRadius: Single;
    fBottomArrowHeadHeight: Single;
    fBottomArrowHeadRadius: Single;
    FHeadStackingStyle: TgxArrowHeadStyle;
  protected
    procedure SetTopRadius(const aValue: Single);
    procedure SetTopArrowHeadHeight(const aValue: Single);
    procedure SetTopArrowHeadRadius(const aValue: Single);
    procedure SetBottomArrowHeadHeight(const aValue: Single);
    procedure SetBottomArrowHeadRadius(const aValue: Single);
    procedure SetParts(aValue: TgxArrowLineParts);
    procedure SetHeadStackingStyle(const val: TgxArrowHeadStyle);
  public
    constructor Create(AOwner: TComponent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    procedure Assign(Source: TPersistent); override;
  published
    property TopRadius: Single read FTopRadius write SetTopRadius;
    property HeadStackingStyle: TgxArrowHeadStyle read FHeadStackingStyle
      write SetHeadStackingStyle default ahssStacked;
    property Parts: TgxArrowLineParts read FParts write SetParts
      default [alLine, alTopArrow];
    property TopArrowHeadHeight: Single read fTopArrowHeadHeight
      write SetTopArrowHeadHeight;
    property TopArrowHeadRadius: Single read fTopArrowHeadRadius
      write SetTopArrowHeadRadius;
    property BottomArrowHeadHeight: Single read fBottomArrowHeadHeight
      write SetBottomArrowHeadHeight;
    property BottomArrowHeadRadius: Single read fBottomArrowHeadRadius
      write SetBottomArrowHeadRadius;
  end;

  TgxArrowArcPart = (aaArc, aaTopArrow, aaBottomArrow);
  TgxArrowArcParts = set of TgxArrowArcPart;

  (* Draws an arrowhead (Sliced Torus + cone).
    The arrow head is a cone that shares the attributes of the Torus
    (ie stacks/slices, materials etc).
    This is useful for displaying a movement (eg twist) or
    other arc arrows that might be required.
    By default the bottom arrow is off *)
  TgxArrowArc = class(TgxCylinderBase)
  private
    fArcRadius: Single;
    FStartAngle: Single;
    FStopAngle: Single;
    FParts: TgxArrowArcParts;
    FTopRadius: Single;
    fTopArrowHeadHeight: Single;
    fTopArrowHeadRadius: Single;
    fBottomArrowHeadHeight: Single;
    fBottomArrowHeadRadius: Single;
    FHeadStackingStyle: TgxArrowHeadStyle;
    FMesh: array of array of TVertexRec;
  protected
    procedure SetArcRadius(const aValue: Single);
    procedure SetStartAngle(const aValue: Single);
    procedure SetStopAngle(const aValue: Single);
    procedure SetTopRadius(const aValue: Single);
    procedure SetTopArrowHeadHeight(const aValue: Single);
    procedure SetTopArrowHeadRadius(const aValue: Single);
    procedure SetBottomArrowHeadHeight(const aValue: Single);
    procedure SetBottomArrowHeadRadius(const aValue: Single);
    procedure SetParts(aValue: TgxArrowArcParts);
    procedure SetHeadStackingStyle(const val: TgxArrowHeadStyle);
  public
    constructor Create(AOwner: TComponent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    procedure Assign(Source: TPersistent); override;
  published
    property ArcRadius: Single read fArcRadius write SetArcRadius;
    property StartAngle: Single read FStartAngle write SetStartAngle;
    property StopAngle: Single read FStopAngle write SetStopAngle;
    property TopRadius: Single read FTopRadius write SetTopRadius;
    property HeadStackingStyle: TgxArrowHeadStyle read FHeadStackingStyle
      write SetHeadStackingStyle default ahssStacked;
    property Parts: TgxArrowArcParts read FParts write SetParts
      default [aaArc, aaTopArrow];
    property TopArrowHeadHeight: Single read fTopArrowHeadHeight
      write SetTopArrowHeadHeight;
    property TopArrowHeadRadius: Single read fTopArrowHeadRadius
      write SetTopArrowHeadRadius;
    property BottomArrowHeadHeight: Single read fBottomArrowHeadHeight
      write SetBottomArrowHeadHeight;
    property BottomArrowHeadRadius: Single read fBottomArrowHeadRadius
      write SetBottomArrowHeadRadius;
  end;

  TgxPolygonPart = (ppTop, ppBottom);
  TgxPolygonParts = set of TgxPolygonPart;

  (* A basic polygon object.
    The curve is described by the Nodes and SplineMode properties, should be
    planar and is automatically tessellated.
    Texture coordinates are deduced from X and Y coordinates only.
    This object allows only for polygons described by a single curve, if you
    need "complex polygons" with holes, patches and cutouts, see GLMultiPolygon. *)
  TgxPolygon = class(TgxPolygonBase)
  private
    FParts: TgxPolygonParts;
  protected
    procedure SetParts(const val: TgxPolygonParts);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
  published
    { Parts of polygon.
      The 'top' of the polygon is the position were the curve describing
      the polygon spin counter-clockwise (i.e. right handed convention). }
    property Parts: TgxPolygonParts read FParts write SetParts default [ppTop, ppBottom];
  end;

  TFrustrumPart = (fpTop, fpBottom, fpFront, fpBack, fpLeft, fpRight);
  TFrustrumParts = set of TFrustrumPart;

const
  cAllFrustrumParts = [fpTop, fpBottom, fpFront, fpBack, fpLeft, fpRight];

type
  (* A frustrum is a pyramid with the top chopped off.
    The height of the imaginary pyramid is ApexHeight, the height of the
    frustrum is Height. If ApexHeight and Height are the same, the frustrum
    degenerates into a pyramid.
    Height cannot be greater than ApexHeight. *)
  TgxFrustrum = class(TgxSceneObject)
  private
    FApexHeight, FBaseDepth, FBaseWidth, FHeight: Single;
    FParts: TFrustrumParts;
    FNormalDirection: TgxNormalDirection;
    procedure SetApexHeight(const aValue: Single);
    procedure SetBaseDepth(const aValue: Single);
    procedure SetBaseWidth(const aValue: Single);
    procedure SetHeight(const aValue: Single);
    procedure SetParts(aValue: TFrustrumParts);
    procedure SetNormalDirection(aValue: TgxNormalDirection);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadData(Stream: TStream);
    procedure WriteData(Stream: TStream);
  public
    constructor Create(AOwner: TComponent); override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    procedure Assign(Source: TPersistent); override;
    function TopDepth: Single;
    function TopWidth: Single;
    function AxisAlignedBoundingBoxUnscaled: TAABB;
    function AxisAlignedDimensionsUnscaled: TVector4f; override;
  published
    property ApexHeight: Single read FApexHeight write SetApexHeight
      stored False;
    property BaseDepth: Single read FBaseDepth write SetBaseDepth
      stored False;
    property BaseWidth: Single read FBaseWidth write SetBaseWidth
      stored False;
    property Height: Single read FHeight write SetHeight stored False;
    property NormalDirection: TgxNormalDirection read FNormalDirection
      write SetNormalDirection default ndOutside;
    property Parts: TFrustrumParts read FParts write SetParts
      default cAllFrustrumParts;
  end;
  
//--------------------- TGLTeapot -------------------------
(* The classic teapot.
    The only use of this object is as placeholder for testing... *)
  TgxTeapot = class(TgxSceneObject)
  private
    FGrid: Cardinal;
  public
    constructor Create(AOwner: TComponent); override;
    function AxisAlignedDimensionsUnscaled: TVector4f; override;
    procedure BuildList(var rci: TgxRenderContextInfo); override;
    procedure DoRender(var ARci: TgxRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;
  end;

// -------------------------------------------------------------
implementation
// -------------------------------------------------------------

// --------------------
// --------------------  TgxTetrahedron ------------------------
// --------------------

procedure TgxTetrahedron.BuildList(var rci: TgxRenderContextInfo);
const
  Vertices: packed array [0 .. 3] of TAffineVector =
   ((X: 1.0; Y: 1.0; Z: 1.0),
    (X: 1.0; Y: - 1.0; Z: - 1.0),
    (X: - 1.0; Y: 1.0; Z: - 1.0),
    (X: - 1.0; Y: - 1.0; Z: 1.0));
  Triangles: packed array [0 .. 3] of packed array [0 .. 2]
    of Byte = ((0, 1, 3), (2, 1, 0), (3, 2, 0), (1, 2, 3));
var
  i, j: Integer;
  n: TAffineVector;
  faceIndices: PByteArray;
begin
  for i := 0 to 3 do
  begin
    faceIndices := @Triangles[i, 0];
    n := CalcPlaneNormal(Vertices[faceIndices^[0]], Vertices[faceIndices^[1]],
      Vertices[faceIndices^[2]]);
    glNormal3fv(@n);
    glBegin(GL_TRIANGLES);
    for j := 0 to 2 do
      glVertex3fv(@Vertices[faceIndices^[j]]);
    glEnd;
  end;
end;

// --------------------
// --------------------  TgxOctahedron ------------------------
// --------------------

procedure TgxOctahedron.BuildList(var rci: TgxRenderContextInfo);
const
  Vertices: packed array [0 .. 5] of TAffineVector =
   ((X: 1.0; Y: 0.0; Z: 0.0),
    (X: - 1.0; Y: 0.0; Z: 0.0),
    (X: 0.0; Y: 1.0; Z: 0.0),
    (X: 0.0; Y: - 1.0; Z: 0.0),
    (X: 0.0; Y: 0.0; Z: 1.0),
    (X: 0.0; Y: 0.0; Z: - 1.0));
  Triangles: packed array [0 .. 7] of packed array [0 .. 2]
    of Byte = ((0, 4, 2), (1, 2, 4), (0, 3, 4), (1, 4, 3), (0, 2, 5), (1, 5, 2),
    (0, 5, 3), (1, 3, 5));

var
  i, j: Integer;
  n: TAffineVector;
  faceIndices: PByteArray;
begin
  for i := 0 to 7 do
  begin
    faceIndices := @Triangles[i, 0];

    n := CalcPlaneNormal(Vertices[faceIndices^[0]], Vertices[faceIndices^[1]],
      Vertices[faceIndices^[2]]);
    glNormal3fv(@n);
    glBegin(GL_TRIANGLES);
    for j := 0 to 2 do
      glVertex3fv(@Vertices[faceIndices^[j]]);
    glEnd;
  end;
end;

// ------------------
// ------------------ TgxHexahedron ------------------
// ------------------

procedure TgxHexahedron.BuildList(var rci: TgxRenderContextInfo);
const
  Vertices: packed array [0 .. 7] of TAffineVector =
   ((X: - 1; Y: - 1; Z: - 1),
    (X: 1; Y: - 1; Z: - 1),
    (X: 1; Y: - 1; Z: 1),
    (X: - 1; Y: - 1; Z: 1),
    (X: - 1; Y: 1; Z: - 1),
    (X: 1; Y: 1; Z: - 1),
    (X: 1; Y: 1; Z: 1),
    (X: - 1; Y: 1; Z: 1));
  Quadrangles: packed array [0 .. 5] of packed array [0 .. 3]
    of Byte = ((0, 1, 2, 3), (3, 2, 6, 7), (7, 6, 5, 4), (4, 5, 1, 0),
    (0, 3, 7, 4), (1, 5, 6, 2));

var
  i, j: Integer;
  n: TAffineVector;
  faceIndices: PByteArray;
begin
  for i := 0 to 4 do
  begin
    faceIndices := @Quadrangles[i, 0];
    n := CalcPlaneNormal(Vertices[faceIndices^[0]], Vertices[faceIndices^[1]],
      Vertices[faceIndices^[2]]);
    glNormal3fv(@n);
    glBegin(GL_QUADS);
    for j := 0 to 7 do
      glVertex3fv(@Vertices[faceIndices^[j]]);
    glEnd;
  end;
end;

// ------------------
// ------------------ TgxDodecahedron ------------------
// ------------------

procedure TgxDodecahedron.BuildList(var rci: TgxRenderContextInfo);
const
  A = 1.61803398875 * 0.3; // (Sqrt(5)+1)/2
  B = 0.61803398875 * 0.3; // (Sqrt(5)-1)/2
  C = 1 * 0.3;
const
  Vertices: packed array [0 .. 19] of TAffineVector = ((X: - A; Y: 0; Z: B),
    (X: - A; Y: 0; Z: - B), (X: A; Y: 0; Z: - B), (X: A; Y: 0; Z: B), (X: B;
    Y: - A; Z: 0), (X: - B; Y: - A; Z: 0), (X: - B; Y: A; Z: 0), (X: B; Y: A;
    Z: 0), (X: 0; Y: B; Z: - A), (X: 0; Y: - B; Z: - A), (X: 0; Y: - B; Z: A),
    (X: 0; Y: B; Z: A), (X: - C; Y: - C; Z: C), (X: - C; Y: - C; Z: - C), (X: C;
    Y: - C; Z: - C), (X: C; Y: - C; Z: C), (X: - C; Y: C; Z: C), (X: - C; Y: C;
    Z: - C), (X: C; Y: C; Z: - C), (X: C; Y: C; Z: C));

  Polygons: packed array [0 .. 11] of packed array [0 .. 4]
    of Byte = ((0, 12, 10, 11, 16), (1, 17, 8, 9, 13), (2, 14, 9, 8, 18),
    (3, 19, 11, 10, 15), (4, 14, 2, 3, 15), (5, 12, 0, 1, 13),
    (6, 17, 1, 0, 16), (7, 19, 3, 2, 18), (8, 17, 6, 7, 18), (9, 14, 4, 5, 13),
    (10, 12, 5, 4, 15), (11, 19, 7, 6, 16));
var
  i, j: Integer;
  n: TAffineVector;
  faceIndices: PByteArray;
begin
  for i := 0 to 11 do
  begin
    faceIndices := @Polygons[i, 0];
    n := CalcPlaneNormal(Vertices[faceIndices^[0]], Vertices[faceIndices^[1]],
      Vertices[faceIndices^[2]]);
    glNormal3fv(@n);

    // glBegin(GL_TRIANGLE_FAN);
    // for j := 0 to 4 do
    // glVertex3fv(@vertices[faceIndices^[j]]);
    // glEnd;

    glBegin(GL_TRIANGLES);
    for j := 1 to 3 do
    begin
      glVertex3fv(@Vertices[faceIndices^[0]]);
      glVertex3fv(@Vertices[faceIndices^[j]]);
      glVertex3fv(@Vertices[faceIndices^[j + 1]]);
    end;
    glEnd;
  end;
end;

// ------------------
// ------------------ TgxIcosahedron ------------------
// ------------------

procedure TgxIcosahedron.BuildList(var rci: TgxRenderContextInfo);
const
  A = 0.5;
  B = 0.30901699437; // 1/(1+Sqrt(5))
const
  Vertices: packed array [0 .. 11] of TAffineVector = ((X: 0; Y: - B; Z: - A),
    (X: 0; Y: - B; Z: A), (X: 0; Y: B; Z: - A), (X: 0; Y: B; Z: A), (X: - A;
    Y: 0; Z: - B), (X: - A; Y: 0; Z: B), (X: A; Y: 0; Z: - B), (X: A; Y: 0;
    Z: B), (X: - B; Y: - A; Z: 0), (X: - B; Y: A; Z: 0), (X: B; Y: - A; Z: 0),
    (X: B; Y: A; Z: 0));
  Triangles: packed array [0 .. 19] of packed array [0 .. 2]
    of Byte = ((2, 9, 11), (3, 11, 9), (3, 5, 1), (3, 1, 7), (2, 6, 0),
    (2, 0, 4), (1, 8, 10), (0, 10, 8), (9, 4, 5), (8, 5, 4), (11, 7, 6),
    (10, 6, 7), (3, 9, 5), (3, 7, 11), (2, 4, 9), (2, 11, 6), (0, 8, 4),
    (0, 6, 10), (1, 5, 8), (1, 10, 7));

var
  i, j: Integer;
  n: TAffineVector;
  faceIndices: PByteArray;
begin
  for i := 0 to 19 do
  begin
    faceIndices := @Triangles[i, 0];

    n := CalcPlaneNormal(Vertices[faceIndices^[0]], Vertices[faceIndices^[1]],
      Vertices[faceIndices^[2]]);
    glNormal3fv(@n);

    glBegin(GL_TRIANGLES);
    for j := 0 to 2 do
      glVertex3fv(@Vertices[faceIndices^[j]]);
    glEnd;
  end;
end;
// ------------------
// ------------------ TgxDisk ------------------
// ------------------

constructor TgxDisk.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOuterRadius := 0.5;
  FInnerRadius := 0;
  FSlices := 16;
  FLoops := 2;
  FStartAngle := 0;
  FSweepAngle := 360;
end;

procedure TgxDisk.BuildList(var rci: TgxRenderContextInfo);
var
  quadric: GLUquadricObj;
begin
  quadric := gluNewQuadric();
  SetupQuadricParams(@quadric);
  gluPartialDisk(quadric, FInnerRadius, FOuterRadius, FSlices, FLoops,
    FStartAngle, FSweepAngle);
  gluDeleteQuadric(quadric);
end;

procedure TgxDisk.SetOuterRadius(const aValue: Single);
begin
  if aValue <> FOuterRadius then
  begin
    FOuterRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxDisk.SetInnerRadius(const aValue: Single);
begin
  if aValue <> FInnerRadius then
  begin
    FInnerRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxDisk.SetSlices(aValue: integer);
begin
  if aValue <> FSlices then
  begin
    FSlices := aValue;
    StructureChanged;
  end;
end;

procedure TgxDisk.SetLoops(aValue: integer);
begin
  if aValue <> FLoops then
  begin
    FLoops := aValue;
    StructureChanged;
  end;
end;

procedure TgxDisk.SetStartAngle(const aValue: Single);
begin
  if aValue <> FStartAngle then
  begin
    FStartAngle := aValue;
    StructureChanged;
  end;
end;

procedure TgxDisk.SetSweepAngle(const aValue: Single);
begin
  if aValue <> FSweepAngle then
  begin
    FSweepAngle := aValue;
    StructureChanged;
  end;
end;

procedure TgxDisk.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxDisk) then
  begin
    FOuterRadius := TgxDisk(Source).FOuterRadius;
    FInnerRadius := TgxDisk(Source).FInnerRadius;
    FSlices := TgxDisk(Source).FSlices;
    FLoops := TgxDisk(Source).FLoops;
    FStartAngle := TgxDisk(Source).FStartAngle;
    FSweepAngle := TgxDisk(Source).FSweepAngle;
  end;
  inherited Assign(Source);
end;

function TgxDisk.AxisAlignedDimensionsUnscaled: TVector4f;
var
  r: Single;
begin
  r := Abs(FOuterRadius);
  Result := VectorMake(r, r, 0);
end;

function TgxDisk.RayCastIntersect(const rayStart, rayVector: TVector4f;
  intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil): Boolean;
var
  ip: TVector4f;
  d: Single;
  angle, beginAngle, endAngle: Single;
  localIntPoint: TVector4f;
begin
  Result := False;
  if SweepAngle > 0 then
    if RayCastPlaneIntersect(rayStart, rayVector, AbsolutePosition,
      AbsoluteDirection, @ip) then
    begin
      if Assigned(intersectPoint) then
        SetVector(intersectPoint^, ip);
      localIntPoint := AbsoluteToLocal(ip);
      d := VectorNorm(localIntPoint);
      if (d >= Sqr(InnerRadius)) and (d <= Sqr(OuterRadius)) then
      begin
        if SweepAngle >= 360 then
          Result := true
        else
        begin
          // arctan2 returns results between -pi and +pi, we want between 0 and 360
          angle := 180 / pi * ArcTan2(localIntPoint.X, localIntPoint.Y);
          if angle < 0 then
            angle := angle + 360;
          // we also want StartAngle and StartAngle+SweepAngle to be in this range
          beginAngle := Trunc(StartAngle) mod 360;
          endAngle := Trunc(StartAngle + SweepAngle) mod 360;
          // If beginAngle>endAngle then area crosses the boundary from 360=>0 degrees
          // therefore have 2 valid regions  (beginAngle to 360) & (0 to endAngle)
          // otherwise just 1 valid region (beginAngle to endAngle)
          if beginAngle > endAngle then
          begin
            if (angle > beginAngle) or (angle < endAngle) then
              Result := true;
          end
          else if (angle > beginAngle) and (angle < endAngle) then
            Result := true;
        end;
      end;
    end;
  if Result then
    if Assigned(intersectNormal) then
      SetVector(intersectNormal^, AbsoluteUp);

end;

// ------------------
// ------------------ TgxCylinderBase ------------------
// ------------------

constructor TgxCylinderBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBottomRadius := 0.5;
  FHeight := 1;
  FSlices := 16;
  FStacks := 4;
  FLoops := 1;
end;

procedure TgxCylinderBase.SetBottomRadius(const aValue: Single);
begin
  if aValue <> FBottomRadius then
  begin
    FBottomRadius := aValue;
    StructureChanged;
  end;
end;

function TgxCylinderBase.GetTopRadius: Single;
begin
  Result := FBottomRadius;
end;

procedure TgxCylinderBase.SetHeight(const aValue: Single);
begin
  if aValue <> FHeight then
  begin
    FHeight := aValue;
    StructureChanged;
  end;
end;

procedure TgxCylinderBase.SetSlices(aValue: GLint);
begin
  if aValue <> FSlices then
  begin
    FSlices := aValue;
    StructureChanged;
  end;
end;

procedure TgxCylinderBase.SetStacks(aValue: GLint);
begin
  if aValue <> FStacks then
  begin
    FStacks := aValue;
    StructureChanged;
  end;
end;

procedure TgxCylinderBase.SetLoops(aValue: GLint);
begin
  if (aValue >= 1) and (aValue <> FLoops) then
  begin
    FLoops := aValue;
    StructureChanged;
  end;
end;

procedure TgxCylinderBase.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxCylinderBase) then
  begin
    FBottomRadius := TgxCylinderBase(Source).FBottomRadius;
    FSlices := TgxCylinderBase(Source).FSlices;
    FStacks := TgxCylinderBase(Source).FStacks;
    FLoops := TgxCylinderBase(Source).FLoops;
    FHeight := TgxCylinderBase(Source).FHeight;
  end;
  inherited Assign(Source);
end;

function TgxCylinderBase.GenerateSilhouette(const silhouetteParameters
  : TgxSilhouetteParameters): TgxSilhouette;
var
  connectivity: TConnectivity;
  sil: TgxSilhouette;
  ShadowSlices: integer;

  i: integer;
  p: array [0 .. 3] of TVector3f;
  PiDivSlices: Single;
  a1, a2: Single;
  c1, c2: TVector3f;
  cosa1, cosa2, sina1, sina2: Single;
  HalfHeight: Single;
  ShadowTopRadius: Single;
begin
  connectivity := TConnectivity.Create(true);

  ShadowSlices := FSlices div 1;

  if FSlices < 5 then
    FSlices := 5;

  PiDivSlices := 2 * pi / ShadowSlices;

  a1 := 0;

  // Is this a speed improvement or just a waste of code?
  HalfHeight := FHeight / 2;

  MakeVector(c1, 0, -HalfHeight, 0);
  MakeVector(c2, 0, HalfHeight, 0);

  ShadowTopRadius := GetTopRadius;

  for i := 0 to ShadowSlices - 1 do
  begin
    a2 := a1 + PiDivSlices;

    // Is this a speed improvement or just a waste of code?
    cosa1 := cos(a1);
    cosa2 := cos(a2);
    sina1 := sin(a1);
    sina2 := sin(a2);

    // Generate the four "corners";
    // Bottom corners
    MakeVector(p[0], FBottomRadius * sina2, -HalfHeight, FBottomRadius * cosa2);
    MakeVector(p[1], FBottomRadius * sina1, -HalfHeight, FBottomRadius * cosa1);

    // Top corners
    MakeVector(p[2], ShadowTopRadius * sina1, HalfHeight,
      ShadowTopRadius * cosa1);
    MakeVector(p[3], ShadowTopRadius * sina2, HalfHeight,
      ShadowTopRadius * cosa2); // }

    // This should be optimized to use AddIndexedFace, because this method
    // searches for each of the vertices and adds them or re-uses them.

    // Skin
    connectivity.AddFace(p[2], p[1], p[0]);
    connectivity.AddFace(p[3], p[2], p[0]);

    // Sides / caps
    connectivity.AddFace(c1, p[0], p[1]);
    connectivity.AddFace(p[2], p[3], c2);

    a1 := a1 + PiDivSlices;
  end;

  sil := nil;
  connectivity.CreateSilhouette(silhouetteParameters, sil, False);

  Result := sil;

  connectivity.Free;
end;

// ------------------
// ------------------ TgxCone ------------------
// ------------------

constructor TgxCone.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParts := [coSides, coBottom];
end;

procedure TgxCone.BuildList(var rci: TgxRenderContextInfo);
var
  quadric: GLUquadricObj;
begin
  glPushMatrix;
  quadric := gluNewQuadric();
  SetupQuadricParams(@quadric);
  glRotated(-90, 1, 0, 0);
  glTranslatef(0, 0, -FHeight * 0.5);
  if coSides in FParts then
    gluCylinder(quadric, BottomRadius, 0, Height, Slices, Stacks);
  if coBottom in FParts then
  begin
    // top of a disk is defined as outside
    SetInvertedQuadricOrientation(@quadric);
    gluDisk(quadric, 0, BottomRadius, Slices, FLoops);
  end;
  gluDeleteQuadric(quadric);
  glPopMatrix;
end;

procedure TgxCone.SetParts(aValue: TgxConeParts);
begin
  if aValue <> FParts then
  begin
    FParts := aValue;
    StructureChanged;
  end;
end;

procedure TgxCone.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxCone) then
  begin
    FParts := TgxCone(Source).FParts;
  end;
  inherited Assign(Source);
end;

function TgxCone.AxisAlignedDimensionsUnscaled: TVector4f;
var
  r: Single;
begin
  r := Abs(FBottomRadius);
  Result := VectorMake(r { *Scale.DirectX } , 0.5 * FHeight { *Scale.DirectY } ,
    r { *Scale.DirectZ } );
end;

function TgxCone.GetTopRadius: Single;
begin
  Result := 0;
end;

function TgxCone.RayCastIntersect(const rayStart, rayVector: TVector4f;
  intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil): Boolean;
var
  ip, localRayStart, localRayVector: TVector4f;
  poly: array [0 .. 2] of Double;
  roots: TDoubleArray;
  minRoot: Double;
  d, t, hconst: Single;
begin
  Result := False;
  localRayStart := AbsoluteToLocal(rayStart);
  localRayVector := VectorNormalize(AbsoluteToLocal(rayVector));

  if coBottom in Parts then
  begin
    // bottom can only be raycast from beneath
    if localRayStart.Y < -FHeight * 0.5 then
    begin
      if RayCastPlaneIntersect(localRayStart, localRayVector,
        PointMake(0, -FHeight * 0.5, 0), YHmgVector, @ip) then
      begin
        d := VectorNorm(ip.X, ip.Z);
        if (d <= Sqr(BottomRadius)) then
        begin
          Result := true;
          if Assigned(intersectPoint) then
            SetVector(intersectPoint^, LocalToAbsolute(ip));
          if Assigned(intersectNormal) then
            SetVector(intersectNormal^, VectorNegate(AbsoluteUp));
          Exit;
        end;
      end;
    end;
  end;
  if coSides in Parts then
  begin
    hconst := -Sqr(BottomRadius) / Sqr(Height);
    // intersect against infinite cones (in positive and negative direction)
    poly[0] := Sqr(localRayStart.X) + hconst *
               Sqr(localRayStart.Y - 0.5 * FHeight) +
               Sqr(localRayStart.Z);
    poly[1] := 2 * (localRayStart.X * localRayVector.X + hconst *
                   (localRayStart.Y - 0.5 * FHeight) * localRayVector.Y +
                    localRayStart.Z* localRayVector.Z);
    poly[2] := Sqr(localRayVector.X) + hconst * Sqr(localRayVector.Y) +
               Sqr(localRayVector.Z);
    SetLength(roots, 0);
    roots := SolveQuadric(@poly);
    if MinPositiveCoef(roots, minRoot) then
    begin
      t := minRoot;
      ip := VectorCombine(localRayStart, localRayVector, 1, t);
      // check that intersection with infinite cone is within the range we want
      if (ip.Y > -FHeight * 0.5) and (ip.Y < FHeight * 0.5) then
      begin
        Result := true;
        if Assigned(intersectPoint) then
          intersectPoint^ := LocalToAbsolute(ip);
        if Assigned(intersectNormal) then
        begin
          ip.Y := hconst * (ip.Y - 0.5 * Height);
          ip.W := 0;
          NormalizeVector(ip);
          intersectNormal^ := LocalToAbsolute(ip);
        end;
      end;
    end;
  end;
end;

// ------------------
// ------------------ TgxCylinder ------------------
// ------------------

constructor TgxCylinder.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTopRadius := 0.5;
  FParts := [cySides, cyBottom, cyTop];
  FAlignment := caCenter;
end;

procedure TgxCylinder.BuildList(var rci: TgxRenderContextInfo);
var
  quadric: GLUquadricObj;
begin
  glPushMatrix;
  quadric := gluNewQuadric;
  SetupQuadricParams(@Quadric);
  glRotatef(-90, 1, 0, 0);
  case Alignment of
    caTop:
      glTranslatef(0, 0, -FHeight);
    caBottom:
      ;
  else // caCenter
    glTranslatef(0, 0, -FHeight * 0.5);
  end;
  if cySides in FParts then
    gluCylinder(Quadric, FBottomRadius, FTopRadius, FHeight, FSlices, FStacks);
  if cyTop in FParts then
  begin
    glPushMatrix;
    glTranslatef(0, 0, FHeight);
    gluDisk(Quadric, 0, FTopRadius, FSlices, FLoops);
    glPopMatrix;
  end;
  if cyBottom in FParts then
  begin
    // swap quadric orientation because top of a disk is defined as outside
    SetInvertedQuadricOrientation(@quadric);
    gluDisk(quadric, 0, FBottomRadius, FSlices, FLoops);
  end;
  gluDeleteQuadric(Quadric);
  glPopMatrix;
end;

procedure TgxCylinder.SetTopRadius(const aValue: Single);
begin
  if aValue <> FTopRadius then
  begin
    FTopRadius := aValue;
    StructureChanged;
  end;
end;

function TgxCylinder.GetTopRadius: Single;
begin
  Result := FTopRadius;
end;

procedure TgxCylinder.SetParts(aValue: TgxCylinderParts);
begin
  if aValue <> FParts then
  begin
    FParts := aValue;
    StructureChanged;
  end;
end;

procedure TgxCylinder.SetAlignment(val: TgxCylinderAlignment);
begin
  if val <> FAlignment then
  begin
    FAlignment := val;
    StructureChanged;
  end;
end;

procedure TgxCylinder.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxCylinder) then
  begin
    FParts := TgxCylinder(Source).FParts;
    FTopRadius := TgxCylinder(Source).FTopRadius;
  end;
  inherited Assign(Source);
end;

function TgxCylinder.AxisAlignedDimensionsUnscaled: TVector4f;
var
  r, r1: Single;
begin
  r := Abs(FBottomRadius);
  r1 := Abs(FTopRadius);
  if r1 > r then
    r := r1;
  Result := VectorMake(r, 0.5 * FHeight, r);
  // ScaleVector(Result, Scale.AsVector);
end;

function TgxCylinder.RayCastIntersect(const rayStart, rayVector: TVector4f;
  intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil): Boolean;
const
  cOne: Single = 1;
var
  locRayStart, locRayVector, ip: TVector4f;
  poly: array [0 .. 2] of Double;
  roots: TDoubleArray;
  minRoot: Double;
  t, tr2, invRayVector1, hTop, hBottom: Single;
  tPlaneMin, tPlaneMax: Single;
begin
  Result := False;
  locRayStart := AbsoluteToLocal(rayStart);
  locRayVector := AbsoluteToLocal(rayVector);

  case Alignment of
    caTop:
      begin
        hTop := 0;
        hBottom := -Height;
      end;
    caBottom:
      begin
        hTop := Height;
        hBottom := 0;
      end;
  else
    // caCenter
    hTop := Height * 0.5;
    hBottom := -hTop;
  end;

  if locRayVector.Y = 0 then
  begin
    // intersect if ray shot through the top/bottom planes
    if (locRayStart.X > hTop) or (locRayStart.X < hBottom) then
      Exit;
    tPlaneMin := -1E99;
    tPlaneMax := 1E99;
  end
  else
  begin
    invRayVector1 := cOne / locRayVector.Y;
    tr2 := Sqr(TopRadius);

    // compute intersection with topPlane
    t := (hTop - locRayStart.Y) * invRayVector1;
    if (t > 0) and (cyTop in Parts) then
    begin
      ip.X := locRayStart.X + t * locRayVector.X;
      ip.Z := locRayStart.Z + t * locRayVector.Z;
      if Sqr(ip.X) + Sqr(ip.Z) <= tr2 then
      begin
        // intersect with top plane
        if Assigned(intersectPoint) then
          intersectPoint^ := LocalToAbsolute(VectorMake(ip.X, hTop, ip.Z, 1));
        if Assigned(intersectNormal) then
          intersectNormal^ := LocalToAbsolute(YHmgVector);
        Result := true;
      end;
    end;
    tPlaneMin := t;
    tPlaneMax := t;
    // compute intersection with bottomPlane
    t := (hBottom - locRayStart.Y) * invRayVector1;
    if (t > 0) and (cyBottom in Parts) then
    begin
      ip.X := locRayStart.X + t * locRayVector.X;
      ip.Z := locRayStart.Z + t * locRayVector.Z;
      if (t < tPlaneMin) or (not(cyTop in Parts)) then
      begin
        if Sqr(ip.X) + Sqr(ip.Z) <= tr2 then
        begin
          // intersect with top plane
          if Assigned(intersectPoint) then
            intersectPoint^ := LocalToAbsolute(VectorMake(ip.X, hBottom,
              ip.Z, 1));
          if Assigned(intersectNormal) then
            intersectNormal^ := LocalToAbsolute(VectorNegate(YHmgVector));
          Result := true;
        end;
      end;
    end;
    if t < tPlaneMin then
      tPlaneMin := t;
    if t > tPlaneMax then
      tPlaneMax := t;
  end;
  if cySides in Parts then
  begin
    // intersect against cylinder infinite cylinder
    poly[0] := Sqr(locRayStart.X) + Sqr(locRayStart.Z) - Sqr(TopRadius);
    poly[1] := 2 * (locRayStart.X * locRayVector.X + locRayStart.Z *
      locRayVector.Z);
    poly[2] := Sqr(locRayVector.X) + Sqr(locRayVector.Z);
    roots := SolveQuadric(@poly);
    if MinPositiveCoef(roots, minRoot) then
    begin
      t := minRoot;
      if (t >= tPlaneMin) and (t < tPlaneMax) then
      begin
        if Assigned(intersectPoint) or Assigned(intersectNormal) then
        begin
          ip := VectorCombine(locRayStart, locRayVector, 1, t);
          if Assigned(intersectPoint) then
            intersectPoint^ := LocalToAbsolute(ip);
          if Assigned(intersectNormal) then
          begin
            ip.Y := 0;
            ip.W := 0;
            intersectNormal^ := LocalToAbsolute(ip);
          end;
        end;
        Result := true;
      end;
    end;
  end
  else
    SetLength(roots, 0);
end;

procedure TgxCylinder.Align(const startPoint, endPoint: TVector4f);
var
  dir: TAffineVector;
begin
  AbsolutePosition := startPoint;
  VectorSubtract(endPoint, startPoint, dir);
  if Parent <> nil then
    dir := Parent.AbsoluteToLocal(dir);
  Up.AsAffineVector := dir;
  Height := VectorLength(dir);
  Lift(Height * 0.5);
  Alignment := caCenter;
end;

procedure TgxCylinder.Align(const startObj, endObj: TgxBaseSceneObject);
begin
  Align(startObj.AbsolutePosition, endObj.AbsolutePosition);
end;

procedure TgxCylinder.Align(const startPoint, endPoint: TAffineVector);
begin
  Align(PointMake(startPoint), PointMake(endPoint));
end;

// ------------------
// ------------------ TgxCapsule ------------------
// ------------------

constructor TgxCapsule.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHeight := 1;
  FRadius := 0.5;
  FSlices := 4;
  FStacks := 4;
  FParts := [cySides, cyBottom, cyTop];
  FAlignment := caCenter;
end;

procedure TgxCapsule.BuildList(var rci: TgxRenderContextInfo);
var
  i, j, n: integer;
  start_nx2: Single;
  start_ny2: Single;
  tmp, nx, ny, nz, start_nx, start_ny, a, ca, sa, l: Single;
  nx2, ny2, nz2: Single;
begin
  glPushMatrix;
  glRotatef(-90, 0, 0, 1);
  case Alignment of
    caTop:
      glTranslatef(0, 0, FHeight + 1);
    caBottom:
      glTranslatef(0, 0, -FHeight);
  else // caCenter
    glTranslatef(0, 0, 0.5);
  end;
  n := FSlices * FStacks;
  l := FHeight;
  l := l * 0.5;
  a := (pi * 2.0) / n;
  sa := sin(a);
  ca := cos(a);
  ny := 0;
  nz := 1;
  if cySides in FParts then
  begin
    glBegin(GL_TRIANGLE_STRIP);
    for i := 0 to n do
    begin
      glNormal3d(ny, nz, 0);
      glTexCoord2f(i / n, 1);
      glVertex3d(ny * FRadius, nz * FRadius, l - 0.5);
      glNormal3d(ny, nz, 0);
      glTexCoord2f(i / n, 0);
      glVertex3d(ny * FRadius, nz * FRadius, -l - 0.5);
      tmp := ca * ny - sa * nz;
      nz := sa * ny + ca * nz;
      ny := tmp;
    end;
    glEnd();
  end;
  //
  if cyTop in FParts then
  begin
    start_nx := 0;
    start_ny := 1;
    for j := 0 to (n div FStacks) do
    begin
      start_nx2 := ca * start_nx + sa * start_ny;
      start_ny2 := -sa * start_nx + ca * start_ny;
      nx := start_nx;
      ny := start_ny;
      nz := 0;
      nx2 := start_nx2;
      ny2 := start_ny2;
      nz2 := 0;
      glPushMatrix;
      glTranslatef(0, 0, -0.5);
      glBegin(GL_TRIANGLE_STRIP);
      for i := 0 to n do
      begin
        glNormal3d(ny2, nz2, nx2);
        glTexCoord2f(i / n, j / n);
        glVertex3d(ny2 * FRadius, nz2 * FRadius, l + nx2 * FRadius);
        glNormal3d(ny, nz, nx);
        glTexCoord2f(i / n, (j - 1) / n);
        glVertex3d(ny * FRadius, nz * FRadius, l + nx * FRadius);
        tmp := ca * ny - sa * nz;
        nz := sa * ny + ca * nz;
        ny := tmp;
        tmp := ca * ny2 - sa * nz2;
        nz2 := sa * ny2 + ca * nz2;
        ny2 := tmp;
      end;
      glEnd();
      glPopMatrix;
      start_nx := start_nx2;
      start_ny := start_ny2;
    end;
  end;
  //
  if cyBottom in FParts then
  begin
    start_nx := 0;
    start_ny := 1;
    for j := 0 to (n div FStacks) do
    begin
      start_nx2 := ca * start_nx - sa * start_ny;
      start_ny2 := sa * start_nx + ca * start_ny;
      nx := start_nx;
      ny := start_ny;
      nz := 0;
      nx2 := start_nx2;
      ny2 := start_ny2;
      nz2 := 0;
      glPushMatrix;
      glTranslatef(0, 0, -0.5);
      glBegin(GL_TRIANGLE_STRIP);
      for i := 0 to n do
      begin
        glNormal3d(ny, nz, nx);
        glTexCoord2f(i / n, (j - 1) / n);
        glVertex3d(ny * FRadius, nz * FRadius, -l + nx * FRadius);
        glNormal3d(ny2, nz2, nx2);
        glTexCoord2f(i / n, j / n);
        glVertex3d(ny2 * FRadius, nz2 * FRadius, -l + nx2 * FRadius);
        tmp := ca * ny - sa * nz;
        nz := sa * ny + ca * nz;
        ny := tmp;
        tmp := ca * ny2 - sa * nz2;
        nz2 := sa * ny2 + ca * nz2;
        ny2 := tmp;
      end;
      glEnd();
      glPopMatrix;
      start_nx := start_nx2;
      start_ny := start_ny2;
    end;
  end;
  glPopMatrix;
end;

procedure TgxCapsule.SetHeight(const aValue: Single);
begin
  if aValue <> FHeight then
  begin
    FHeight := aValue;
    StructureChanged;
  end;
end;

procedure TgxCapsule.SetRadius(const aValue: Single);
begin
  if aValue <> FRadius then
  begin
    FRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxCapsule.SetSlices(const aValue: integer);
begin
  if aValue <> FSlices then
  begin
    FSlices := aValue;
    StructureChanged;
  end;
end;

procedure TgxCapsule.SetStacks(const aValue: integer);
begin
  if aValue <> FStacks then
  begin
    FStacks := aValue;
    StructureChanged;
  end;
end;

procedure TgxCapsule.SetParts(aValue: TgxCylinderParts);
begin
  if aValue <> FParts then
  begin
    FParts := aValue;
    StructureChanged;
  end;
end;

procedure TgxCapsule.SetAlignment(val: TgxCylinderAlignment);
begin
  if val <> FAlignment then
  begin
    FAlignment := val;
    StructureChanged;
  end;
end;

procedure TgxCapsule.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxCapsule) then
  begin
    FParts := TgxCapsule(Source).FParts;
    FRadius := TgxCapsule(Source).FRadius;
  end;
  inherited Assign(Source);
end;

function TgxCapsule.AxisAlignedDimensionsUnscaled: TVector4f;
var
  r, r1: Single;
begin
  r := Abs(FRadius);
  r1 := Abs(FRadius);
  if r1 > r then
    r := r1;
  Result := VectorMake(r, 0.5 * FHeight, r);
  // ScaleVector(Result, Scale.AsVector);
end;

function TgxCapsule.RayCastIntersect(const rayStart, rayVector: TVector4f;
  intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil): Boolean;
const
  cOne: Single = 1;
var
  locRayStart, locRayVector, ip: TVector4f;
  poly: array [0 .. 2] of Double;
  roots: TDoubleArray;
  minRoot: Double;
  t, tr2, invRayVector1, hTop, hBottom: Single;
  tPlaneMin, tPlaneMax: Single;
begin
  Result := False;
  locRayStart := AbsoluteToLocal(rayStart);
  locRayVector := AbsoluteToLocal(rayVector);
  case Alignment of
    caTop:
      begin
        hTop := 0;
        hBottom := -FHeight;
      end;
    caBottom:
      begin
        hTop := FHeight;
        hBottom := 0;
      end;
  else
    // caCenter
    hTop := FHeight * 0.5;
    hBottom := -hTop;
  end;
  if locRayVector.Y = 0 then
  begin
    // intersect if ray shot through the top/bottom planes
    if (locRayStart.X > hTop) or (locRayStart.X < hBottom) then
      Exit;
    tPlaneMin := -1E99;
    tPlaneMax := 1E99;
  end
  else
  begin
    invRayVector1 := cOne / locRayVector.Y;
    tr2 := Sqr(Radius);
    // compute intersection with topPlane
    t := (hTop - locRayStart.Y) * invRayVector1;
    if (t > 0) and (cyTop in Parts) then
    begin
      ip.X := locRayStart.X + t * locRayVector.X;
      ip.Z := locRayStart.Z + t * locRayVector.Z;
      if Sqr(ip.X) + Sqr(ip.Z) <= tr2 then
      begin
        // intersect with top plane
        if Assigned(intersectPoint) then
          intersectPoint^ := LocalToAbsolute(VectorMake(ip.X, hTop, ip.Z, 1));
        if Assigned(intersectNormal) then
          intersectNormal^ := LocalToAbsolute(YHmgVector);
        Result := true;
      end;
    end;
    tPlaneMin := t;
    tPlaneMax := t;
    // compute intersection with bottomPlane
    t := (hBottom - locRayStart.Y) * invRayVector1;
    if (t > 0) and (cyBottom in Parts) then
    begin
      ip.X := locRayStart.X + t * locRayVector.X;
      ip.Z := locRayStart.Z + t * locRayVector.Z;
      if (t < tPlaneMin) or (not(cyTop in Parts)) then
      begin
        if Sqr(ip.X) + Sqr(ip.Z) <= tr2 then
        begin
          // intersect with top plane
          if Assigned(intersectPoint) then
            intersectPoint^ := LocalToAbsolute(VectorMake(ip.X, hBottom,
              ip.Z, 1));
          if Assigned(intersectNormal) then
            intersectNormal^ := LocalToAbsolute(VectorNegate(YHmgVector));
          Result := true;
        end;
      end;
    end;
    if t < tPlaneMin then
      tPlaneMin := t;
    if t > tPlaneMax then
      tPlaneMax := t;
  end;
  if cySides in Parts then
  begin
    // intersect against cylinder infinite cylinder
    poly[0] := Sqr(locRayStart.X) + Sqr(locRayStart.Z) - Sqr(Radius);
    poly[1] := 2 * (locRayStart.X * locRayVector.X +
                    locRayStart.Z * locRayVector.Z);
    poly[2] := Sqr(locRayVector.X) + Sqr(locRayVector.Z);
    roots := SolveQuadric(@poly);
    if MinPositiveCoef(roots, minRoot) then
    begin
      t := minRoot;
      if (t >= tPlaneMin) and (t < tPlaneMax) then
      begin
        if Assigned(intersectPoint) or Assigned(intersectNormal) then
        begin
          ip := VectorCombine(locRayStart, locRayVector, 1, t);
          if Assigned(intersectPoint) then
            intersectPoint^ := LocalToAbsolute(ip);
          if Assigned(intersectNormal) then
          begin
            ip.Y := 0;
            ip.W := 0;
            intersectNormal^ := LocalToAbsolute(ip);
          end;
        end;
        Result := true;
      end;
    end;
  end
  else
    SetLength(roots, 0);
end;

procedure TgxCapsule.Align(const startPoint, endPoint: TVector4f);
var
  dir: TAffineVector;
begin
  AbsolutePosition := startPoint;
  VectorSubtract(endPoint, startPoint, dir);
  if Parent <> nil then
    dir := Parent.AbsoluteToLocal(dir);
  Up.AsAffineVector := dir;
  FHeight := VectorLength(dir);
  Lift(FHeight * 0.5);
  Alignment := caCenter;
end;

procedure TgxCapsule.Align(const startObj, endObj: TgxBaseSceneObject);
begin
  Align(startObj.AbsolutePosition, endObj.AbsolutePosition);
end;

procedure TgxCapsule.Align(const startPoint, endPoint: TAffineVector);
begin
  Align(PointMake(startPoint), PointMake(endPoint));
end;

// ------------------
// ------------------ TgxAnnulus ------------------
// ------------------

constructor TgxAnnulus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBottomInnerRadius := 0.3;
  FTopInnerRadius := 0.3;
  FTopRadius := 0.5;
  FParts := [anInnerSides, anOuterSides, anBottom, anTop];
end;

procedure TgxAnnulus.SetBottomInnerRadius(const aValue: Single);
begin
  if aValue <> FBottomInnerRadius then
  begin
    FBottomInnerRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxAnnulus.SetTopRadius(const aValue: Single);
begin
  if aValue <> FTopRadius then
  begin
    FTopRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxAnnulus.SetTopInnerRadius(const aValue: Single);
begin
  if aValue <> FTopInnerRadius then
  begin
    FTopInnerRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxAnnulus.SetParts(aValue: TgxAnnulusParts);
begin
  if aValue <> FParts then
  begin
    FParts := aValue;
    StructureChanged;
  end;
end;

procedure TgxAnnulus.BuildList(var rci: TgxRenderContextInfo);
var
  quadric: GLUquadricObj;
begin
  glPushMatrix;
  quadric := gluNewQuadric;
  SetupQuadricParams(@quadric);
  glRotatef(-90, 1, 0, 0);
  glTranslatef(0, 0, -FHeight * 0.5);
  if anOuterSides in FParts then
    gluCylinder(quadric, FBottomRadius, FTopRadius, FHeight, FSlices, FStacks);
  if anTop in FParts then
  begin
    glPushMatrix;
    glTranslatef(0, 0, FHeight);
    gluDisk(quadric, FTopInnerRadius, FTopRadius, FSlices, FLoops);
    glPopMatrix;
  end;
  if [anBottom, anInnerSides] * FParts <> [] then
  begin
    // swap quadric orientation because top of a disk is defined as outside
    SetInvertedQuadricOrientation(@quadric);
    if anBottom in FParts then
      gluDisk(quadric, FBottomInnerRadius, FBottomRadius, FSlices, FLoops);
    if anInnerSides in FParts then
      gluCylinder(quadric, FBottomInnerRadius, FTopInnerRadius, FHeight,
        FSlices, FStacks);
  end;
  gluDeleteQuadric(quadric);
  glPopMatrix;
end;

procedure TgxAnnulus.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxAnnulus) then
  begin
    FParts := TgxAnnulus(Source).FParts;
    FTopRadius := TgxAnnulus(Source).FTopRadius;
    FTopInnerRadius := TgxAnnulus(Source).FTopInnerRadius;
    FBottomRadius := TgxAnnulus(Source).FBottomRadius;
    FBottomInnerRadius := TgxAnnulus(Source).FBottomInnerRadius;
  end;
  inherited Assign(Source);
end;

function TgxAnnulus.AxisAlignedDimensionsUnscaled: TVector4f;
var
  r, r1: Single;
begin
  r := Abs(FBottomRadius);
  r1 := Abs(FTopRadius);
  if r1 > r then
    r := r1;
  Result := VectorMake(r, 0.5 * FHeight, r);
end;

function TgxAnnulus.RayCastIntersect(const rayStart, rayVector: TVector4f;
  intersectPoint, intersectNormal: PVector4f): Boolean;
const
  cOne: Single = 1;
var
  locRayStart, locRayVector, ip: TVector4f;
  poly: array [0 .. 2] of Double;
  t, tr2, invRayVector1: Single;
  tPlaneMin, tPlaneMax: Single;
  tir2, d2: Single;
  Root: Double;
  roots, tmpRoots: TDoubleArray;
  FirstIntersected: Boolean;
  h1, h2, hTop, hBot: Single;
  Draw1, Draw2: Boolean;
begin
  Result := False;
  FirstIntersected := False;
  SetLength(tmpRoots, 0);
  locRayStart := AbsoluteToLocal(rayStart);
  locRayVector := AbsoluteToLocal(rayVector);
  hTop := Height * 0.5;
  hBot := -hTop;
  if locRayVector.Y < 0 then
  begin // Sort the planes according to the direction of view
    h1 := hTop; // Height of the 1st plane
    h2 := hBot; // Height of the 2nd plane
    Draw1 := (anTop in Parts); // 1st "cap" Must be drawn?
    Draw2 := (anBottom in Parts);
  end
  else
  begin
    h1 := hBot;
    h2 := hTop;
    Draw1 := (anBottom in Parts);
    Draw2 := (anTop in Parts);
  end; // if

  if locRayVector.Y = 0 then
  begin
    // intersect if ray shot through the top/bottom planes
    if (locRayStart.X > hTop) or (locRayStart.X < hBot) then
      Exit;
    tPlaneMin := -1E99;
    tPlaneMax := 1E99;
  end
  else
  begin
    invRayVector1 := cOne / locRayVector.Y;
    tr2 := Sqr(TopRadius);
    tir2 := Sqr(TopInnerRadius);
    FirstIntersected := False;
    // compute intersection with first plane
    t := (h1 - locRayStart.Y) * invRayVector1;
    if (t > 0) and Draw1 then
    begin
      ip.X := locRayStart.X + t * locRayVector.X;
      ip.Z := locRayStart.Z + t * locRayVector.Z;
      d2 := Sqr(ip.X) + Sqr(ip.Z);
      if (d2 <= tr2) and (d2 >= tir2) then
      begin
        // intersect with top plane
        FirstIntersected := true;
        if Assigned(intersectPoint) then
          intersectPoint^ := LocalToAbsolute(VectorMake(ip.X, h1, ip.Z, 1));
        if Assigned(intersectNormal) then
          intersectNormal^ := LocalToAbsolute(YHmgVector);
        Result := true;
      end;
    end;
    tPlaneMin := t;
    tPlaneMax := t;
    // compute intersection with second plane
    t := (h2 - locRayStart.Y) * invRayVector1;
    if (t > 0) and Draw2 then
    begin
      ip.X := locRayStart.X + t * locRayVector.X;
      ip.Z := locRayStart.Z + t * locRayVector.Z;
      d2 := Sqr(ip.X) + Sqr(ip.Z);
      if (t < tPlaneMin) or (not FirstIntersected) then
      begin
        if (d2 <= tr2) and (d2 >= tir2) then
        begin
          // intersect with top plane
          if Assigned(intersectPoint) then
            intersectPoint^ := LocalToAbsolute(VectorMake(ip.X, h2, ip.Z, 1));
          if Assigned(intersectNormal) then
            intersectNormal^ := LocalToAbsolute(VectorNegate(YHmgVector));
          Result := true;
        end;
      end;
    end;
    if t < tPlaneMin then
    begin
      tPlaneMin := t;
    end; // if
    if t > tPlaneMax then
      tPlaneMax := t;
  end;

  try
    SetLength(roots, 4);
    roots[0] := -1;
    roots[1] := -1;
    roots[2] := -1;
    roots[3] := -1; // By default, side is behind rayStart
    // Compute roots for outer cylinder
    if anOuterSides in Parts then
    begin
      // intersect against infinite cylinder, will be cut by tPlaneMine and tPlaneMax
      poly[0] := Sqr(locRayStart.X) + Sqr(locRayStart.Z) - Sqr(TopRadius);
      poly[1] := 2 * (locRayStart.X * locRayVector.X + locRayStart.Z *
        locRayVector.Z);
      poly[2] := Sqr(locRayVector.X) + Sqr(locRayVector.Z);
      tmpRoots := SolveQuadric(@poly);
      // Intersect coordinates on rayVector (rayStart=0)
      if ( High(tmpRoots) >= 0) and // Does root exist?
        ((tmpRoots[0] > tPlaneMin) and not FirstIntersected) and
      // In the annulus and not masked by first cap
        ((tmpRoots[0] < tPlaneMax)) { // In the annulus } then
        roots[0] := tmpRoots[0];
      if ( High(tmpRoots) >= 1) and
        ((tmpRoots[1] > tPlaneMin) and not FirstIntersected) and
        ((tmpRoots[1] < tPlaneMax)) then
        roots[1] := tmpRoots[1];
    end; // if
    // Compute roots for inner cylinder
    if anInnerSides in Parts then
    begin
      // intersect against infinite cylinder
      poly[0] := Sqr(locRayStart.X) +
                 Sqr(locRayStart.Z) - Sqr(TopInnerRadius);
      poly[1] := 2 * (locRayStart.X * locRayVector.X +
                 locRayStart.Z * locRayVector.Z);
      poly[2] := Sqr(locRayVector.X) + Sqr(locRayVector.Z);
                 tmpRoots := SolveQuadric(@poly);
      if ( High(tmpRoots) >= 0) and
        ((tmpRoots[0] > tPlaneMin) and not FirstIntersected) and
        ((tmpRoots[0] < tPlaneMax)) then
        roots[2] := tmpRoots[0];
      if ( High(tmpRoots) >= 1) and
        ((tmpRoots[1] > tPlaneMin) and not FirstIntersected) and
        ((tmpRoots[1] < tPlaneMax)) then
        roots[3] := tmpRoots[1];
    end; // if
    // Find the first intersection point and compute its coordinates and normal
    if MinPositiveCoef(roots, Root) then
    begin
      t := Root;
      if (t >= tPlaneMin) and (t < tPlaneMax) then
      begin
        if Assigned(intersectPoint) or Assigned(intersectNormal) then
        begin
          ip := VectorCombine(locRayStart, locRayVector, 1, t);
          if Assigned(intersectPoint) then
            intersectPoint^ := LocalToAbsolute(ip);
          if Assigned(intersectNormal) then
          begin
            ip.Y := 0;
            ip.W := 0;
            intersectNormal^ := LocalToAbsolute(ip);
          end;
        end;
        Result := true;
      end;
    end;
  finally
    roots := nil;
    tmpRoots := nil;
  end; // finally
end;

// ------------------
// ------------------ TgxTorus ------------------
// ------------------

constructor TgxTorus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRings := 25;
  FSides := 15;
  FMinorRadius := 0.1;
  FMajorRadius := 0.4;
  FStartAngle := 0.0;
  FStopAngle := 360.0;
  FParts := [toSides, toStartDisk, toStopDisk];
end;

procedure TgxTorus.BuildList(var rci: TgxRenderContextInfo);

  procedure EmitVertex(ptr: PVertexRec; L1, L2: integer);
  begin
    glTexCoord2fv(@ptr^.TexCoord);
    begin
      glNormal3fv(@ptr^.Normal);
      if L1 > -1 then
        glVertexAttrib3fv(L1, @ptr.Tangent);
      if L2 > -1 then
        glVertexAttrib3fv(L2, @ptr.Binormal);
      glVertex3fv(@ptr^.Position);
    end;
  end;

var
  i, j: integer;
  Theta, Phi, Theta1, cosPhi, sinPhi, dist: Single;
  cosTheta1, sinTheta1: Single;
  ringDelta, sideDelta: Single;
  ringDir: TAffineVector;
  iFact, jFact: Single;
  pVertex: PVertexRec;
  TanLoc, BinLoc: Integer;
  MeshSize: integer;
  MeshIndex: integer;
  Vertex: TVertexRec;
begin
  if FMesh = nil then
  begin
    MeshSize := 0;
    MeshIndex := 0;
    if toStartDisk in FParts then
      MeshSize := MeshSize + 1;
    if toStopDisk in FParts then
      MeshSize := MeshSize + 1;
    if toSides in FParts then
      MeshSize := MeshSize + Integer(FRings) + 1;
    SetLength(FMesh, MeshSize);
    // handle texture generation
    ringDelta := ((FStopAngle - FStartAngle) / 360) * c2PI / FRings;
    sideDelta := c2PI / FSides;
    iFact := 1 / FRings;
    jFact := 1 / FSides;
    if toSides in FParts then
    begin
      Theta := DegToRadian(FStartAngle) - ringDelta;
      for i := FRings downto 0 do
      begin
        SetLength(FMesh[i], FSides + 1);
        Theta1 := Theta + ringDelta;
        SinCosine(Theta1, sinTheta1, cosTheta1);
        Phi := 0;
        for j := FSides downto 0 do
        begin
          Phi := Phi + sideDelta;
          SinCosine(Phi, sinPhi, cosPhi);
          dist := FMajorRadius + FMinorRadius * cosPhi;

          FMesh[i][j].Position := Vector3fMake(cosTheta1 * dist,
            -sinTheta1 * dist, FMinorRadius * sinPhi);
          ringDir := FMesh[i][j].Position;
          ringDir.Z := 0.0;
          NormalizeVector(ringDir);
          FMesh[i][j].Normal := Vector3fMake(cosTheta1 * cosPhi,
            -sinTheta1 * cosPhi, sinPhi);
          FMesh[i][j].Tangent := VectorCrossProduct(ZVector, ringDir);
          FMesh[i][j].Binormal := VectorCrossProduct(FMesh[i][j].Normal,
            FMesh[i][j].Tangent);
          FMesh[i][j].TexCoord := Vector2fMake(i * iFact, j * jFact);
        end;
        Theta := Theta1;
      end;
      MeshIndex := FRings + 1;
    end;
    if toStartDisk in FParts then
    begin
      SetLength(FMesh[MeshIndex], FSides + 1);
      Theta1 := DegToRadian(FStartAngle);
      SinCosine(Theta1, sinTheta1, cosTheta1);
      if toSides in FParts then
      begin
        for j := FSides downto 0 do
        begin
          FMesh[MeshIndex][j].Position := FMesh[MeshIndex - 1][j].Position;
          FMesh[MeshIndex][j].Normal := FMesh[MeshIndex - 1][j].Tangent;
          FMesh[MeshIndex][j].Tangent := FMesh[MeshIndex - 1][j].Position;
          FMesh[MeshIndex][j].Tangent.Z := 0;
          FMesh[MeshIndex][j].Binormal := ZVector;
          FMesh[MeshIndex][j].TexCoord := FMesh[MeshIndex - 1][j].TexCoord;
          FMesh[MeshIndex][j].TexCoord.X := 0;
        end;
      end
      else
      begin
        Phi := 0;
        for j := FSides downto 0 do
        begin
          Phi := Phi + sideDelta;
          SinCosine(Phi, sinPhi, cosPhi);
          dist := FMajorRadius + FMinorRadius * cosPhi;
          FMesh[MeshIndex][j].Position := Vector3fMake(cosTheta1 * dist,
            -sinTheta1 * dist, FMinorRadius * sinPhi);
          ringDir := FMesh[MeshIndex][j].Position;
          ringDir.Z := 0.0;
          NormalizeVector(ringDir);
          FMesh[MeshIndex][j].Normal := VectorCrossProduct(ZVector, ringDir);
          FMesh[MeshIndex][j].Tangent := ringDir;
          FMesh[MeshIndex][j].Binormal := ZVector;
          FMesh[MeshIndex][j].TexCoord := Vector2fMake(0, j * jFact);
        end;
      end;
      Vertex.Position := Vector3fMake(cosTheta1 * FMajorRadius,
        -sinTheta1 * FMajorRadius, 0);
      Vertex.Normal := FMesh[MeshIndex][0].Normal;
      Vertex.Tangent := FMesh[MeshIndex][0].Tangent;
      Vertex.Binormal := FMesh[MeshIndex][0].Binormal;
      Vertex.TexCoord := Vector2fMake(1, 1);
      MeshIndex := MeshIndex + 1;
    end;
    if toStopDisk in FParts then
    begin
      SetLength(FMesh[MeshIndex], FSides + 1);
      Theta1 := DegToRadian(FStopAngle);
      SinCosine(Theta1, sinTheta1, cosTheta1);
      if toSides in FParts then
      begin
        for j := FSides downto 0 do
        begin
          FMesh[MeshIndex][j].Position := FMesh[0][j].Position;
          FMesh[MeshIndex][j].Normal := VectorNegate(FMesh[0][j].Tangent);
          FMesh[MeshIndex][j].Tangent := FMesh[0][j].Position;
          FMesh[MeshIndex][j].Tangent.Z := 0;
          FMesh[MeshIndex][j].Binormal := VectorNegate(ZVector);
          FMesh[MeshIndex][j].TexCoord := FMesh[0][j].TexCoord;
          FMesh[MeshIndex][j].TexCoord.X := 1;
        end;
      end
      else
      begin
        Phi := 0;
        for j := FSides downto 0 do
        begin
          Phi := Phi + sideDelta;
          SinCosine(Phi, sinPhi, cosPhi);
          dist := FMajorRadius + FMinorRadius * cosPhi;
          FMesh[MeshIndex][j].Position := Vector3fMake(cosTheta1 * dist,
            -sinTheta1 * dist, FMinorRadius * sinPhi);
          ringDir := FMesh[MeshIndex][j].Position;
          ringDir.Z := 0.0;
          NormalizeVector(ringDir);
          FMesh[MeshIndex][j].Normal := VectorCrossProduct(ringDir, ZVector);
          FMesh[MeshIndex][j].Tangent := ringDir;
          FMesh[MeshIndex][j].Binormal := VectorNegate(ZVector);
          FMesh[MeshIndex][j].TexCoord := Vector2fMake(1, j * jFact);
        end;
      end;
      Vertex.Position := Vector3fMake(cosTheta1 * FMajorRadius,
        -sinTheta1 * FMajorRadius, 0);
      Vertex.Normal := FMesh[MeshIndex][0].Normal;
      Vertex.Tangent := FMesh[MeshIndex][0].Tangent;
      Vertex.Binormal := FMesh[MeshIndex][0].Binormal;
      Vertex.TexCoord := Vector2fMake(0, 0);
    end;
  end;

  begin
    if {GL_ARB_shader_objects and} (rci.gxStates.CurrentProgram > 0) then
    begin
      TanLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
        PGLChar(TangentAttributeName));
      BinLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
        PGLChar(BinormalAttributeName));
    end
    else
    begin
      TanLoc := -1;
      BinLoc := TanLoc;
    end;
    MeshIndex := 0;
    if toSides in FParts then
    begin
      glBegin(GL_TRIANGLES);
      for i := FRings - 1 downto 0 do
        for j := FSides - 1 downto 0 do
        begin
          pVertex := @FMesh[i][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[i][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[i + 1][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[i + 1][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[i + 1][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[i][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
        end;
      glEnd;
      MeshIndex := FRings + 1;
    end;
    if toStartDisk in FParts then
    begin
      glBegin(GL_TRIANGLE_FAN);
      pVertex := @Vertex;
      EmitVertex(pVertex, TanLoc, BinLoc);
      for j := 0 to FSides do
      begin
        pVertex := @FMesh[MeshIndex][j];
        EmitVertex(pVertex, TanLoc, BinLoc);
      end;
      glEnd;
      MeshIndex := MeshIndex + 1;
    end;
    if toStopDisk in FParts then
    begin
      glBegin(GL_TRIANGLE_FAN);
      pVertex := @Vertex;
      EmitVertex(pVertex, TanLoc, BinLoc);
      for j := FSides downto 0 do
      begin
        pVertex := @FMesh[MeshIndex][j];
        EmitVertex(pVertex, TanLoc, BinLoc);
      end;
      glEnd;
    end;
  end;
end;

procedure TgxTorus.SetMajorRadius(const aValue: Single);
begin
  if FMajorRadius <> aValue then
  begin
    FMajorRadius := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxTorus.SetMinorRadius(const aValue: Single);
begin
  if FMinorRadius <> aValue then
  begin
    FMinorRadius := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxTorus.SetRings(aValue: Cardinal);
begin
  if FRings <> aValue then
  begin
    FRings := aValue;
    if FRings < 2 then
      FRings := 2;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxTorus.SetSides(aValue: Cardinal);
begin
  if FSides <> aValue then
  begin
    FSides := aValue;
    if FSides < 3 then
      FSides := 3;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxTorus.SetStartAngle(const aValue: Single);
begin
  if FStartAngle <> aValue then
  begin
    FStartAngle := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxTorus.SetStopAngle(const aValue: Single);
begin
  if FStopAngle <> aValue then
  begin
    FStopAngle := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxTorus.SetParts(aValue: TgxTorusParts);
begin
  if aValue <> FParts then
  begin
    FParts := aValue;
    StructureChanged;
  end;
end;

function TgxTorus.AxisAlignedDimensionsUnscaled: TVector4f;
var
  r, r1: Single;
begin
  r := Abs(FMajorRadius);
  r1 := Abs(FMinorRadius);
  Result := VectorMake(r + r1, r + r1, r1); // Danb
end;

function TgxTorus.RayCastIntersect(const rayStart, rayVector: TVector4f;
  intersectPoint: PVector4f = nil; intersectNormal: PVector4f = nil): Boolean;
var
  i: integer;
  fRo2, fRi2, fDE, fVal, r, nearest: Double;
  polynom: array [0 .. 4] of Double;
  polyRoots: TDoubleArray;
  localStart, localVector: TVector4f;
  vi, vc: TVector4f;
begin
  // compute coefficients of quartic polynomial
  fRo2 := Sqr(MajorRadius);
  fRi2 := Sqr(MinorRadius);
  localStart := AbsoluteToLocal(rayStart);
  localVector := AbsoluteToLocal(rayVector);
  NormalizeVector(localVector);
  fDE := VectorDotProduct(localStart, localVector);
  fVal := VectorNorm(localStart) - (fRo2 + fRi2);

  polynom[0] := Sqr(fVal) - 4.0 * fRo2 * (fRi2 - Sqr(localStart.Z));
  polynom[1] := 4.0 * fDE * fVal + 8.0 * fRo2 * localVector.Z * localStart.Z;
  polynom[2] := 2.0 * fVal + 4.0 * Sqr(fDE) + 4.0 * fRo2 * Sqr(localVector.Z);
  polynom[3] := 4.0 * fDE;
  polynom[4] := 1;
  // solve the quartic
  polyRoots := SolveQuartic(@polynom[0]);
  // search for closest point
  Result := (Length(polyRoots) > 0);
  if Result then
  begin
    nearest := 1E20;
    for i := 0 to High(polyRoots) do
    begin
      r := polyRoots[i];
      if (r > 0) and (r < nearest) then
      begin
        nearest := r;
        Result := true;
      end;
    end;
    vi := VectorCombine(localStart, localVector, 1, nearest);
    if Assigned(intersectPoint) then
      SetVector(intersectPoint^, LocalToAbsolute(vi));
    if Assigned(intersectNormal) then
    begin
      // project vi on local torus plane
      vc.X := vi.X;
      vc.Y := vi.Y;
      vc.Z := 0;
      // project vc on MajorRadius circle
      ScaleVector(vc, MajorRadius / (VectorLength(vc) + 0.000001));
      // calculate circle to intersect vector (gives normal);
      SubtractVector(vi, vc);
      // return to absolute coordinates and normalize
      vi.W := 0;
      SetVector(intersectNormal^, LocalToAbsolute(vi));
    end;
  end;
end;

// ------------------
// ------------------ TgxArrowLine ------------------
// ------------------

constructor TgxArrowLine.Create(AOwner: TComponent);
begin
  inherited;
  FTopRadius := 0.1;
  BottomRadius := 0.1;
  fTopArrowHeadRadius := 0.2;
  fTopArrowHeadHeight := 0.5;
  fBottomArrowHeadRadius := 0.2;
  fBottomArrowHeadHeight := 0.5;
  FHeadStackingStyle := ahssStacked;
  { by default there is not much point having the top of the line (cylinder)
    showing as it is coincidental with the Toparrowhead bottom.
    Note I've defaulted to "vector" type arrows (arrow head on top only }
  FParts := [alLine, alTopArrow];
end;

procedure TgxArrowLine.SetTopRadius(const aValue: Single);
begin
  if aValue <> FTopRadius then
  begin
    FTopRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxArrowLine.SetTopArrowHeadHeight(const aValue: Single);
begin
  if aValue <> fTopArrowHeadHeight then
  begin
    fTopArrowHeadHeight := aValue;
    StructureChanged;
  end;
end;

procedure TgxArrowLine.SetTopArrowHeadRadius(const aValue: Single);
begin
  if aValue <> fTopArrowHeadRadius then
  begin
    fTopArrowHeadRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxArrowLine.SetBottomArrowHeadHeight(const aValue: Single);
begin
  if aValue <> fBottomArrowHeadHeight then
  begin
    fBottomArrowHeadHeight := aValue;
    StructureChanged;
  end;
end;

procedure TgxArrowLine.SetBottomArrowHeadRadius(const aValue: Single);
begin
  if aValue <> fBottomArrowHeadRadius then
  begin
    fBottomArrowHeadRadius := aValue;
    StructureChanged;
  end;
end;

procedure TgxArrowLine.SetParts(aValue: TgxArrowLineParts);
begin
  if aValue <> FParts then
  begin
    FParts := aValue;
    StructureChanged;
  end;
end;

procedure TgxArrowLine.SetHeadStackingStyle(const val: TgxArrowHeadStyle);
begin
  if val <> FHeadStackingStyle then
  begin
    FHeadStackingStyle := val;
    StructureChanged;
  end;
end;

procedure TgxArrowLine.BuildList(var rci: TgxRenderContextInfo);
var
  quadric: GLUquadricObj;
  cylHeight, cylOffset, headInfluence: Single;
begin
  case HeadStackingStyle of
    ahssCentered:
      headInfluence := 0.5;
    ahssIncluded:
      headInfluence := 1;
  else // ahssStacked
    headInfluence := 0;
  end;
  cylHeight := Height;
  cylOffset := -FHeight * 0.5;
  // create a new quadric
  quadric := gluNewQuadric();
  SetupQuadricParams(@quadric);
  // does the top arrow part - the cone
  if alTopArrow in Parts then
  begin
    cylHeight := cylHeight - TopArrowHeadHeight * headInfluence;
    glPushMatrix;
    glTranslatef(0, 0, Height * 0.5 - TopArrowHeadHeight * headInfluence);
    gluCylinder(quadric, fTopArrowHeadRadius, 0, fTopArrowHeadHeight,
      Slices, Stacks);
    // top of a disk is defined as outside
    SetInvertedQuadricOrientation(@quadric);
    if alLine in Parts then
      gluDisk(quadric, FTopRadius, fTopArrowHeadRadius, Slices, FLoops)
    else
      gluDisk(quadric, 0, fTopArrowHeadRadius, Slices, FLoops);
    glPopMatrix;
  end;
  // does the bottom arrow part - another cone
  if alBottomArrow in Parts then
  begin
    cylHeight := cylHeight - BottomArrowHeadHeight * headInfluence;
    cylOffset := cylOffset + BottomArrowHeadHeight * headInfluence;
    glPushMatrix;
    // make the bottom arrow point in the other direction
    glRotatef(180, 1, 0, 0);
    glTranslatef(0, 0, Height * 0.5 - BottomArrowHeadHeight * headInfluence);
    SetNormalQuadricOrientation(@quadric);
    gluCylinder(quadric, fBottomArrowHeadRadius, 0, fBottomArrowHeadHeight,
      Slices, Stacks);
    // top of a disk is defined as outside
    SetInvertedQuadricOrientation(@quadric);
    if alLine in Parts then
      gluDisk(quadric, FBottomRadius, fBottomArrowHeadRadius, Slices, FLoops)
    else
      gluDisk(quadric, 0, fBottomArrowHeadRadius, Slices, FLoops);
    glPopMatrix;
  end;
  // does the cylinder that makes the line
  if (cylHeight > 0) and (alLine in Parts) then
  begin
    glPushMatrix;
    glTranslatef(0, 0, cylOffset);
    SetNormalQuadricOrientation(@quadric);
    gluCylinder(quadric, FBottomRadius, FTopRadius, cylHeight, FSlices,
      FStacks);
    if not(alTopArrow in Parts) then
    begin
      glPushMatrix;
      glTranslatef(0, 0, cylHeight);
      gluDisk(quadric, 0, FTopRadius, FSlices, FLoops);
      glPopMatrix;
    end;
    if not(alBottomArrow in Parts) then
    begin
      // swap quadric orientation because top of a disk is defined as outside
      SetInvertedQuadricOrientation(@quadric);
      gluDisk(quadric, 0, FBottomRadius, FSlices, FLoops);
    end;
    glPopMatrix;
  end;
  gluDeleteQuadric(quadric);
end;

procedure TgxArrowLine.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxArrowLine) then
  begin
    FParts := TgxArrowLine(Source).FParts;
    FTopRadius := TgxArrowLine(Source).FTopRadius;
    fTopArrowHeadHeight := TgxArrowLine(Source).fTopArrowHeadHeight;
    fTopArrowHeadRadius := TgxArrowLine(Source).fTopArrowHeadRadius;
    fBottomArrowHeadHeight := TgxArrowLine(Source).fBottomArrowHeadHeight;
    fBottomArrowHeadRadius := TgxArrowLine(Source).fBottomArrowHeadRadius;
    FHeadStackingStyle := TgxArrowLine(Source).FHeadStackingStyle;
  end;
  inherited Assign(Source);
end;

// ------------------
// ------------------ TgxArrowArc ------------------
// ------------------

constructor TgxArrowArc.Create(AOwner: TComponent);
begin
  inherited;
  FStacks := 16;
  fArcRadius := 0.5;
  FStartAngle := 0;
  FStopAngle := 360;
  FTopRadius := 0.1;
  BottomRadius := 0.1;
  fTopArrowHeadRadius := 0.2;
  fTopArrowHeadHeight := 0.5;
  fBottomArrowHeadRadius := 0.2;
  fBottomArrowHeadHeight := 0.5;
  FHeadStackingStyle := ahssStacked;
  FParts := [aaArc, aaTopArrow];
end;

procedure TgxArrowArc.SetArcRadius(const aValue: Single);
begin
  if fArcRadius <> aValue then
  begin
    fArcRadius := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetStartAngle(const aValue: Single);
begin
  if FStartAngle <> aValue then
  begin
    FStartAngle := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetStopAngle(const aValue: Single);
begin
  if FStopAngle <> aValue then
  begin
    FStopAngle := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetTopRadius(const aValue: Single);
begin
  if aValue <> FTopRadius then
  begin
    FTopRadius := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetTopArrowHeadHeight(const aValue: Single);
begin
  if aValue <> fTopArrowHeadHeight then
  begin
    fTopArrowHeadHeight := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetTopArrowHeadRadius(const aValue: Single);
begin
  if aValue <> fTopArrowHeadRadius then
  begin
    fTopArrowHeadRadius := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetBottomArrowHeadHeight(const aValue: Single);
begin
  if aValue <> fBottomArrowHeadHeight then
  begin
    fBottomArrowHeadHeight := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetBottomArrowHeadRadius(const aValue: Single);
begin
  if aValue <> fBottomArrowHeadRadius then
  begin
    fBottomArrowHeadRadius := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetParts(aValue: TgxArrowArcParts);
begin
  if aValue <> FParts then
  begin
    FParts := aValue;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.SetHeadStackingStyle(const val: TgxArrowHeadStyle);
begin
  if val <> FHeadStackingStyle then
  begin
    FHeadStackingStyle := val;
    FMesh := nil;
    StructureChanged;
  end;
end;

procedure TgxArrowArc.BuildList(var rci: TgxRenderContextInfo);
  procedure EmitVertex(ptr: PVertexRec; L1, L2: integer);
  begin
    glTexCoord2fv(@ptr^.TexCoord);
    glNormal3fv(@ptr^.Normal);
    if L1 > -1 then
      glVertexAttrib3fv(L1, @ptr.Tangent);
    if L2 > -1 then
      glVertexAttrib3fv(L2, @ptr.Binormal);
    glVertex3fv(@ptr^.Position);
  end;

var
  i, j: integer;
  Theta, Phi, Theta1, cosPhi, sinPhi, dist: Single;
  cosTheta1, sinTheta1: Single;
  ringDelta, sideDelta: Single;
  ringDir: TAffineVector;
  iFact, jFact: Single;
  pVertex: PVertexRec;
  TanLoc, BinLoc: Integer;
  MeshSize: integer;
  MeshIndex: integer;
  ConeCenter: TVertexRec;
  StartOffset, StopOffset: Single;
begin
  if FMesh = nil then
  begin
    MeshIndex := 0;
    MeshSize := 0;
    // Check Parts
    if aaArc in FParts then
      MeshSize := MeshSize + FStacks + 1;
    if aaTopArrow in FParts then
      MeshSize := MeshSize + 3
    else
      MeshSize := MeshSize + 1;
    if aaBottomArrow in FParts then
      MeshSize := MeshSize + 3
    else
      MeshSize := MeshSize + 1;
    // Allocate Mesh
    SetLength(FMesh, MeshSize);
    case FHeadStackingStyle of
      ahssStacked:
        begin
          StartOffset := 0;
          StopOffset := 0;
        end;
      ahssCentered:
        begin
          if aaBottomArrow in Parts then
            StartOffset :=
              RadToDeg(ArcTan(0.5 * fBottomArrowHeadHeight / fArcRadius))
          else
            StartOffset :=0;
          if aaTopArrow in Parts then
            StopOffset :=
              RadToDeg(ArcTan(0.5 * fTopArrowHeadHeight / fArcRadius))
          else
            StopOffset :=0;
        end ;
      ahssIncluded:
        begin
          if aaBottomArrow in Parts then
            StartOffset := RadToDeg(ArcTan(fBottomArrowHeadHeight / fArcRadius))
          else
            StartOffset :=0;
          if aaTopArrow in Parts then
            StopOffset := RadToDeg(ArcTan(fTopArrowHeadHeight / fArcRadius))
          else
            StopOffset :=0;
        end ;
      else
        StartOffset := 0;
        StopOffset := 0;
    end;
    // handle texture generation
    ringDelta := (((FStopAngle - StopOffset) - (FStartAngle + StartOffset)) /
      360) * c2PI / FStacks;
    sideDelta := c2PI / FSlices;
    iFact := 1 / FStacks;
    jFact := 1 / FSlices;
    if aaArc in FParts then
    begin
      Theta := DegToRadian(FStartAngle + StartOffset) - ringDelta;
      for i := FStacks downto 0 do
      begin
        SetLength(FMesh[i], FSlices + 1);
        Theta1 := Theta + ringDelta;
        SinCosine(Theta1, sinTheta1, cosTheta1);
        Phi := 0;
        for j := FSlices downto 0 do
        begin
          Phi := Phi + sideDelta;
          SinCosine(Phi, sinPhi, cosPhi);
          dist := fArcRadius + Lerp(FTopRadius, FBottomRadius, i * iFact) * cosPhi;
          FMesh[i][j].Position := Vector3fMake(cosTheta1 * dist,
            -sinTheta1 * dist, Lerp(FTopRadius, FBottomRadius, i * iFact) * sinPhi);
          ringDir := FMesh[i][j].Position;
          ringDir.Z := 0.0;
          NormalizeVector(ringDir);
          FMesh[i][j].Normal := Vector3fMake(cosTheta1 * cosPhi,
            -sinTheta1 * cosPhi, sinPhi);
          FMesh[i][j].Tangent := VectorCrossProduct(ZVector, ringDir);
          FMesh[i][j].Binormal := VectorCrossProduct(FMesh[i][j].Normal,
            FMesh[i][j].Tangent);
          FMesh[i][j].TexCoord := Vector2fMake(i * iFact, j * jFact);
        end;
        Theta := Theta1;
      end;
      MeshIndex := FStacks + 1;
      begin
        if {GL_ARB_shader_objects and} (rci.gxStates.CurrentProgram > 0) then
        begin
          TanLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(TangentAttributeName));
          BinLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(BinormalAttributeName));
        end
        else
        begin
          TanLoc := -1;
          BinLoc := TanLoc;
        end;

        glBegin(GL_TRIANGLES);
        for i := FStacks - 1 downto 0 do
          for j := FSlices - 1 downto 0 do
          begin
            pVertex := @FMesh[i][j];
            EmitVertex(pVertex, TanLoc, BinLoc);
            pVertex := @FMesh[i][j + 1];
            EmitVertex(pVertex, TanLoc, BinLoc);
            pVertex := @FMesh[i + 1][j];
            EmitVertex(pVertex, TanLoc, BinLoc);
            pVertex := @FMesh[i + 1][j + 1];
            EmitVertex(pVertex, TanLoc, BinLoc);
            pVertex := @FMesh[i + 1][j];
            EmitVertex(pVertex, TanLoc, BinLoc);
            pVertex := @FMesh[i][j + 1];
            EmitVertex(pVertex, TanLoc, BinLoc);
          end;
        glEnd;
      end;
    end;
    // Build Arrow or start cap
    if aaBottomArrow in FParts then
    begin
      SetLength(FMesh[MeshIndex], FSlices + 1);
      SetLength(FMesh[MeshIndex + 1], FSlices + 1);
      SetLength(FMesh[MeshIndex + 2], FSlices + 1);
      Theta1 := DegToRadian(FStartAngle + StartOffset);
      SinCosine(Theta1, sinTheta1, cosTheta1);
      ConeCenter.Position := Vector3fMake(cosTheta1 * fArcRadius,
        -sinTheta1 * fArcRadius, 0);

      Phi := 0;
      for j := FSlices downto 0 do
      begin
        Phi := Phi + sideDelta;
        SinCosine(Phi, sinPhi, cosPhi);
        dist := fArcRadius + fBottomArrowHeadRadius * cosPhi;
        // Cap
        FMesh[MeshIndex][J].Position := Vector3fMake(cosTheta1 * dist,
          -sinTheta1 * dist, fBottomArrowHeadRadius * sinPhi);
        ringDir := FMesh[MeshIndex][j].Position;
        ringDir.Z := 0.0;
        NormalizeVector(ringDir);
        FMesh[MeshIndex][j].Normal := VectorCrossProduct(ringDir, ZVector);
        FMesh[MeshIndex][j].Tangent := ringDir;
        FMesh[MeshIndex][j].Binormal := ZVector;
        FMesh[MeshIndex][j].TexCoord := Vector2fMake(1, j * jFact);
        // Cone
        FMesh[MeshIndex+1][j].Position := Vector3fMake(cosTheta1 * dist,
          -sinTheta1 * dist, fBottomArrowHeadRadius * sinPhi);
        FMesh[MeshIndex+2][j].Position := VectorAdd(ConeCenter.Position,
          Vector3fMake(sinTheta1 * fBottomArrowHeadHeight,
          cosTheta1 * fBottomArrowHeadHeight, 0));
        FMesh[MeshIndex + 1][j].Tangent :=
          VectorNormalize(VectorSubtract(FMesh[MeshIndex + 1][j].Position,
          FMesh[MeshIndex + 2][j].Position));
        FMesh[MeshIndex + 2][j].Tangent := FMesh[MeshIndex + 1][j].Tangent;
        FMesh[MeshIndex + 1][j].Binormal := Vector3fMake(cosTheta1 * -sinPhi,
          sinTheta1 * sinPhi, cosPhi);
        FMesh[MeshIndex + 2][j].Binormal := FMesh[MeshIndex + 1][j].Binormal;
        FMesh[MeshIndex + 1][j].Normal :=
          VectorCrossProduct(FMesh[MeshIndex + 1][j].Binormal,
          FMesh[MeshIndex + 1][j].Tangent);
        FMesh[MeshIndex + 2][j].Normal := FMesh[MeshIndex + 1][j].Normal;
        FMesh[MeshIndex + 1][j].TexCoord := Vector2fMake(0, j * jFact);
        FMesh[MeshIndex + 2][j].TexCoord := Vector2fMake(1, j * jFact);
      end;
      ConeCenter.Normal := FMesh[MeshIndex][0].Normal;
      ConeCenter.Tangent := FMesh[MeshIndex][0].Tangent;
      ConeCenter.Binormal := FMesh[MeshIndex][0].Binormal;
      ConeCenter.TexCoord := Vector2fMake(0, 0);
      begin
        if {GL_ARB_shader_objects and} (rci.gxStates.CurrentProgram > 0) then
        begin
          TanLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(TangentAttributeName));
          BinLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(BinormalAttributeName));
        end
        else
        begin
          TanLoc := -1;
          BinLoc := TanLoc;
        end;

        glBegin(GL_TRIANGLE_FAN);
        pVertex := @ConeCenter;
        EmitVertex(pVertex, TanLoc, BinLoc);
        for j := FSlices downto 0 do
        begin
          pVertex := @FMesh[MeshIndex][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
        end;
        glEnd;

        glBegin(GL_TRIANGLES);

        for j := FSlices - 1 downto 0 do
        begin
          pVertex := @FMesh[MeshIndex + 1][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 1][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 2][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 2][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 2][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 1][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
        end;
        glEnd;

      end;
      MeshIndex := MeshIndex + 3;
    end
    else
    begin
      SetLength(FMesh[MeshIndex], FSlices + 1);
      Theta1 := DegToRadian(FStartAngle);
      SinCosine(Theta1, sinTheta1, cosTheta1);
      Phi := 0;
      for j := FSlices downto 0 do
      begin
        Phi := Phi + sideDelta;
        SinCosine(Phi, sinPhi, cosPhi);
        dist := fArcRadius + fBottomRadius * cosPhi;
        FMesh[MeshIndex][j].Position := Vector3fMake(cosTheta1 * dist,
          -sinTheta1 * dist, FBottomRadius * sinPhi);
        ringDir := FMesh[MeshIndex][j].Position;
        ringDir.Z := 0.0;
        NormalizeVector(ringDir);
        FMesh[MeshIndex][j].Normal := VectorCrossProduct(ZVector, ringDir);
        FMesh[MeshIndex][j].Tangent := ringDir;
        FMesh[MeshIndex][j].Binormal := ZVector;
        FMesh[MeshIndex][j].TexCoord := Vector2fMake(0, j * jFact);
      end;

      ConeCenter.Position := Vector3fMake(cosTheta1 * fArcRadius,
        -sinTheta1 * fArcRadius, 0);
      ConeCenter.Normal := FMesh[MeshIndex][0].Normal;
      ConeCenter.Tangent := FMesh[MeshIndex][0].Tangent;
      ConeCenter.Binormal := FMesh[MeshIndex][0].Binormal;
      ConeCenter.TexCoord := Vector2fMake(1, 1);
      begin
        if {GL_ARB_shader_objects and} (rci.gxStates.CurrentProgram > 0) then
        begin
          TanLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(TangentAttributeName));
          BinLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(BinormalAttributeName));
        end
        else
        begin
          TanLoc := -1;
          BinLoc := TanLoc;
        end;
        glBegin(GL_TRIANGLE_FAN);
        pVertex := @ConeCenter;
        EmitVertex(pVertex, TanLoc, BinLoc);
        for j := 0 to FSlices do
        begin
          pVertex := @FMesh[MeshIndex][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
        end;
        glEnd;
      end;
      MeshIndex := MeshIndex + 1;
    end;

    if aaTopArrow in FParts then
    begin
      SetLength(FMesh[MeshIndex], FSlices + 1);
      SetLength(FMesh[MeshIndex + 1], FSlices + 1);
      SetLength(FMesh[MeshIndex + 2], FSlices + 1);
      Theta1 := DegToRadian(FStopAngle - StopOffset);
      SinCosine(Theta1, sinTheta1, cosTheta1);

      ConeCenter.Position := Vector3fMake(cosTheta1 * fArcRadius,
        -sinTheta1 * fArcRadius, 0);
      Phi := 0;
      for j := FSlices downto 0 do
      begin
        Phi := Phi + sideDelta;
        SinCosine(Phi, sinPhi, cosPhi);
        dist := fArcRadius + fTopArrowHeadRadius * cosPhi;
        // Cap
        FMesh[MeshIndex][j].Position := Vector3fMake(cosTheta1 * dist,
          -sinTheta1 * dist, fTopArrowHeadRadius * sinPhi);
        ringDir := FMesh[MeshIndex][j].Position;
        ringDir.Z := 0.0;
        NormalizeVector(ringDir);
        FMesh[MeshIndex][j].Normal := VectorCrossProduct(ZVector, ringDir);
        FMesh[MeshIndex][j].Tangent := ringDir;
        FMesh[MeshIndex][j].Binormal := ZVector;
        FMesh[MeshIndex][j].TexCoord := Vector2fMake(0, j * jFact);
        // Cone
        FMesh[MeshIndex + 1][j].Position := Vector3fMake(cosTheta1 * dist,
          -sinTheta1 * dist, fTopArrowHeadRadius * sinPhi);
        FMesh[MeshIndex + 2][j].Position := VectorSubtract(ConeCenter.Position,
          Vector3fMake(sinTheta1 * fTopArrowHeadHeight,
          cosTheta1 * fTopArrowHeadHeight, 0));
        FMesh[MeshIndex + 1][j].Tangent :=
          VectorNormalize(VectorSubtract(FMesh[MeshIndex + 2][j].Position,
          FMesh[MeshIndex + 1][j].Position));
        FMesh[MeshIndex + 2][j].Tangent := FMesh[MeshIndex + 1][j].Tangent;
        FMesh[MeshIndex + 1][j].Binormal := Vector3fMake(cosTheta1 * -sinPhi,
          sinTheta1 * sinPhi, cosPhi);
        FMesh[MeshIndex + 2][j].Binormal := FMesh[MeshIndex + 1][j].Binormal;
        FMesh[MeshIndex + 1][j].Normal :=
          VectorCrossProduct(FMesh[MeshIndex + 1][j].Binormal,
          FMesh[MeshIndex + 1][j].Tangent);
        FMesh[MeshIndex + 2][j].Normal := FMesh[MeshIndex + 1][j].Normal;
        FMesh[MeshIndex + 1][j].TexCoord := Vector2fMake(1, j * jFact);
        FMesh[MeshIndex + 2][j].TexCoord := Vector2fMake(0, j * jFact);
      end;
      ConeCenter.Normal := FMesh[MeshIndex][0].Normal;
      ConeCenter.Tangent := FMesh[MeshIndex][0].Tangent;
      ConeCenter.Binormal := FMesh[MeshIndex][0].Binormal;
      ConeCenter.TexCoord := Vector2fMake(1, 1);
      begin
        if {GL_ARB_shader_objects and} (rci.gxStates.CurrentProgram > 0) then
        begin
          TanLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(TangentAttributeName));
          BinLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(BinormalAttributeName));
        end
        else
        begin
          TanLoc := -1;
          BinLoc := TanLoc;
        end;

        glBegin(GL_TRIANGLE_FAN);
        pVertex := @ConeCenter;
        EmitVertex(pVertex, TanLoc, BinLoc);
        for j := 0 to FSlices do
        begin
          pVertex := @FMesh[MeshIndex][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
        end;
        glEnd;

        glBegin(GL_TRIANGLES);

        for j := FSlices - 1 downto 0 do
        begin
          pVertex := @FMesh[MeshIndex + 2][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 2][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 1][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 1][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 1][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
          pVertex := @FMesh[MeshIndex + 2][j + 1];
          EmitVertex(pVertex, TanLoc, BinLoc);
        end;
        glEnd;

      end;
    end
    else
    begin
      SetLength(FMesh[MeshIndex], FSlices + 1);
      Theta1 := DegToRadian(FStopAngle);
      SinCosine(Theta1, sinTheta1, cosTheta1);
      Phi := 0;
      for j := FSlices downto 0 do
      begin
        Phi := Phi + sideDelta;
        SinCosine(Phi, sinPhi, cosPhi);
        dist := fArcRadius + fTopRadius * cosPhi;
        FMesh[MeshIndex][j].Position := Vector3fMake(cosTheta1 * dist,
          -sinTheta1 * dist, fTopRadius * sinPhi);
        ringDir := FMesh[MeshIndex][j].Position;
        ringDir.Z := 0.0;
        NormalizeVector(ringDir);
        FMesh[MeshIndex][j].Normal := VectorCrossProduct(ringDir, ZVector);
        FMesh[MeshIndex][j].Tangent := ringDir;
        FMesh[MeshIndex][j].Binormal := VectorNegate(ZVector);
        FMesh[MeshIndex][j].TexCoord := Vector2fMake(1, j * jFact);
      end;
      ConeCenter.Position := Vector3fMake(cosTheta1 * fArcRadius,
        -sinTheta1 * fArcRadius, 0);
      ConeCenter.Normal := FMesh[MeshIndex][0].Normal;
      ConeCenter.Tangent := FMesh[MeshIndex][0].Tangent;
      ConeCenter.Binormal := FMesh[MeshIndex][0].Binormal;
      ConeCenter.TexCoord := Vector2fMake(0, 0);
      begin
        if {GL_ARB_shader_objects and} (rci.gxStates.CurrentProgram > 0) then
        begin
          TanLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(TangentAttributeName));
          BinLoc := glGetAttribLocation(rci.gxStates.CurrentProgram,
            PGLChar(BinormalAttributeName));
        end
        else
        begin
          TanLoc := -1;
          BinLoc := TanLoc;
        end;
        glBegin(GL_TRIANGLE_FAN);
        pVertex := @ConeCenter;
        EmitVertex(pVertex, TanLoc, BinLoc);
        for j := FSlices downto 0 do
        begin
          pVertex := @FMesh[MeshIndex][j];
          EmitVertex(pVertex, TanLoc, BinLoc);
        end;
        glEnd;
      end;
    end;
  end;
end;

procedure TgxArrowArc.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxArrowLine) then
  begin
    FStartAngle := TgxArrowArc(Source).FStartAngle;
    FStopAngle := TgxArrowArc(Source).FStopAngle;
    fArcRadius := TgxArrowArc(Source).fArcRadius;
    FParts := TgxArrowArc(Source).FParts;
    FTopRadius := TgxArrowArc(Source).FTopRadius;
    fTopArrowHeadHeight := TgxArrowArc(Source).fTopArrowHeadHeight;
    fTopArrowHeadRadius := TgxArrowArc(Source).fTopArrowHeadRadius;
    fBottomArrowHeadHeight := TgxArrowArc(Source).fBottomArrowHeadHeight;
    fBottomArrowHeadRadius := TgxArrowArc(Source).fBottomArrowHeadRadius;
    FHeadStackingStyle := TgxArrowArc(Source).FHeadStackingStyle;
  end;
  inherited Assign(Source);
end;

// ------------------
// ------------------ TgxFrustrum ------------------
// ------------------

constructor TgxFrustrum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FApexHeight := 1;
  FBaseWidth := 1;
  FBaseDepth := 1;
  FHeight := 0.5;
  FParts := cAllFrustrumParts;
  FNormalDirection := ndOutside;
end;

procedure TgxFrustrum.BuildList(var rci: TgxRenderContextInfo);
var
  HBW, HBD: Single; // half of width, half of depth at base
  HTW, HTD: Single; // half of width, half of depth at top of frustrum
  HFH: Single; // half of height, for align to center
  Sign: Single; // +1 or -1
  angle: Single; // in radians
  ASin, ACos: Single;
begin
  if FNormalDirection = ndInside then
    Sign := -1
  else
    Sign := 1;
  HBW := FBaseWidth * 0.5;
  HBD := FBaseDepth * 0.5;
  HTW := HBW * (FApexHeight - FHeight) / FApexHeight;
  HTD := HBD * (FApexHeight - FHeight) / FApexHeight;
  HFH := FHeight * 0.5;

  glBegin(GL_QUADS);

  if [fpFront, fpBack] * FParts <> [] then
  begin
    angle := ArcTan(FApexHeight / HBD);
    // angle of front plane with bottom plane
    SinCosine(angle, ASin, ACos);
    if fpFront in FParts then
    begin
      glNormal3f(0, Sign * ACos, Sign * ASin);
      glTexCoord2fv(@XYTexPoint);
      glVertex3f(HTW, HFH, HTD);
      glTexCoord2fv(@YTexPoint);
      glVertex3f(-HTW, HFH, HTD);
      glTexCoord2fv(@NullTexPoint);
      glVertex3f(-HBW, -HFH, HBD);
      glTexCoord2fv(@XTexPoint);
      glVertex3f(HBW, -HFH, HBD);
    end;
    if fpBack in FParts then
    begin
      glNormal3f(0, Sign * ACos, -Sign * ASin);
      glTexCoord2fv(@YTexPoint);
      glVertex3f(HTW, HFH, -HTD);
      glTexCoord2fv(@NullTexPoint);
      glVertex3f(HBW, -HFH, -HBD);
      glTexCoord2fv(@XTexPoint);
      glVertex3f(-HBW, -HFH, -HBD);
      glTexCoord2fv(@XYTexPoint);
      glVertex3f(-HTW, HFH, -HTD);
    end;
  end;
  if [fpLeft, fpRight] * FParts <> [] then
  begin
    angle := ArcTan(FApexHeight / HBW); // angle of side plane with bottom plane
    SinCosine(angle, ASin, ACos);
    if fpLeft in FParts then
    begin
      glNormal3f(-Sign * ASin, Sign * ACos, 0);
      glTexCoord2fv(@XYTexPoint);
      glVertex3f(-HTW, HFH, HTD);
      glTexCoord2fv(@YTexPoint);
      glVertex3f(-HTW, HFH, -HTD);
      glTexCoord2fv(@NullTexPoint);
      glVertex3f(-HBW, -HFH, -HBD);
      glTexCoord2fv(@XTexPoint);
      glVertex3f(-HBW, -HFH, HBD);
    end;
    if fpRight in FParts then
    begin
      glNormal3f(Sign * ASin, Sign * ACos, 0);
      glTexCoord2fv(@YTexPoint);
      glVertex3f(HTW, HFH, HTD);
      glTexCoord2fv(@NullTexPoint);
      glVertex3f(HBW, -HFH, HBD);
      glTexCoord2fv(@XTexPoint);
      glVertex3f(HBW, -HFH, -HBD);
      glTexCoord2fv(@XYTexPoint);
      glVertex3f(HTW, HFH, -HTD);
    end;
  end;
  if (fpTop in FParts) and (FHeight < FApexHeight) then
  begin
    glNormal3f(0, Sign, 0);
    glTexCoord2fv(@YTexPoint);
    glVertex3f(-HTW, HFH, -HTD);
    glTexCoord2fv(@NullTexPoint);
    glVertex3f(-HTW, HFH, HTD);
    glTexCoord2fv(@XTexPoint);
    glVertex3f(HTW, HFH, HTD);
    glTexCoord2fv(@XYTexPoint);
    glVertex3f(HTW, HFH, -HTD);
  end;
  if fpBottom in FParts then
  begin
    glNormal3f(0, -Sign, 0);
    glTexCoord2fv(@NullTexPoint);
    glVertex3f(-HBW, -HFH, -HBD);
    glTexCoord2fv(@XTexPoint);
    glVertex3f(HBW, -HFH, -HBD);
    glTexCoord2fv(@XYTexPoint);
    glVertex3f(HBW, -HFH, HBD);
    glTexCoord2fv(@YTexPoint);
    glVertex3f(-HBW, -HFH, HBD);
  end;

  glEnd;
end;

procedure TgxFrustrum.SetApexHeight(const aValue: Single);
begin
  if (aValue <> FApexHeight) and (aValue >= 0) then
  begin
    FApexHeight := aValue;
    if FHeight > aValue then
      FHeight := aValue;
    StructureChanged;
  end;
end;

procedure TgxFrustrum.SetBaseDepth(const aValue: Single);
begin
  if (aValue <> FBaseDepth) and (aValue >= 0) then
  begin
    FBaseDepth := aValue;
    StructureChanged;
  end;
end;

procedure TgxFrustrum.SetBaseWidth(const aValue: Single);
begin
  if (aValue <> FBaseWidth) and (aValue >= 0) then
  begin
    FBaseWidth := aValue;
    StructureChanged;
  end;
end;

procedure TgxFrustrum.SetHeight(const aValue: Single);
begin
  if (aValue <> FHeight) and (aValue >= 0) then
  begin
    FHeight := aValue;
    if FApexHeight < aValue then
      FApexHeight := aValue;
    StructureChanged;
  end;
end;

procedure TgxFrustrum.SetParts(aValue: TFrustrumParts);
begin
  if aValue <> FParts then
  begin
    FParts := aValue;
    StructureChanged;
  end;
end;

procedure TgxFrustrum.SetNormalDirection(aValue: TgxNormalDirection);
begin
  if aValue <> FNormalDirection then
  begin
    FNormalDirection := aValue;
    StructureChanged;
  end;
end;

procedure TgxFrustrum.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TgxFrustrum) then
  begin
    FApexHeight := TgxFrustrum(Source).FApexHeight;
    FBaseDepth := TgxFrustrum(Source).FBaseDepth;
    FBaseWidth := TgxFrustrum(Source).FBaseWidth;
    FHeight := TgxFrustrum(Source).FHeight;
    FParts := TgxFrustrum(Source).FParts;
    FNormalDirection := TgxFrustrum(Source).FNormalDirection;
  end;
  inherited Assign(Source);
end;

function TgxFrustrum.TopDepth: Single;
begin
  Result := FBaseDepth * (FApexHeight - FHeight) / FApexHeight;
end;

function TgxFrustrum.TopWidth: Single;
begin
  Result := FBaseWidth * (FApexHeight - FHeight) / FApexHeight;
end;

procedure TgxFrustrum.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('FrustrumSize', ReadData, WriteData,
    (FApexHeight <> 1) or (FBaseDepth <> 1) or (FBaseWidth <> 1) or
    (FHeight <> 0.5));
end;

procedure TgxFrustrum.ReadData(Stream: TStream);
begin
  with Stream do
  begin
    Read(FApexHeight, SizeOf(FApexHeight));
    Read(FBaseDepth, SizeOf(FBaseDepth));
    Read(FBaseWidth, SizeOf(FBaseWidth));
    Read(FHeight, SizeOf(FHeight));
  end;
end;

procedure TgxFrustrum.WriteData(Stream: TStream);
begin
  with Stream do
  begin
    Write(FApexHeight, SizeOf(FApexHeight));
    Write(FBaseDepth, SizeOf(FBaseDepth));
    Write(FBaseWidth, SizeOf(FBaseWidth));
    Write(FHeight, SizeOf(FHeight));
  end;
end;

function TgxFrustrum.AxisAlignedBoundingBoxUnscaled: TAABB;
var
  aabb: TAABB;
  child: TgxBaseSceneObject;
  i: integer;
begin
  SetAABB(Result, AxisAlignedDimensionsUnscaled);
  OffsetAABB(Result, VectorMake(0, FHeight * 0.5, 0));

  // not tested for child objects
  for i := 0 to Count - 1 do
  begin
    child := TgxBaseSceneObject(Children[i]);
    aabb := child.AxisAlignedBoundingBoxUnscaled;
    AABBTransform(aabb, child.Matrix^);
    AddAABB(Result, aabb);
  end;
end;

function TgxFrustrum.AxisAlignedDimensionsUnscaled: TVector4f;
begin
  Result.X := FBaseWidth * 0.5;
  Result.Y := FHeight * 0.5;
  Result.Z := FBaseDepth * 0.5;
  Result.W := 0;
end;

// ------------------
// ------------------ TgxPolygon ------------------
// ------------------

constructor TgxPolygon.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParts := [ppTop, ppBottom];
end;

destructor TgxPolygon.Destroy;
begin
  inherited Destroy;
end;

procedure TgxPolygon.SetParts(const val: TgxPolygonParts);
begin
  if FParts <> val then
  begin
    FParts := val;
    StructureChanged;
  end;
end;

procedure TgxPolygon.Assign(Source: TPersistent);
begin
  if Source is TgxPolygon then
  begin
    FParts := TgxPolygon(Source).FParts;
  end;
  inherited Assign(Source);
end;

procedure TgxPolygon.BuildList(var rci: TgxRenderContextInfo);
var
  Normal: TAffineVector;
  pNorm: PAffineVector;
begin
  if (Nodes.Count > 1) then
  begin
    Normal := Nodes.Normal;
    if VectorIsNull(Normal) then
      pNorm := nil
    else
      pNorm := @Normal;
    if ppTop in FParts then
    begin
      if SplineMode = lsmLines then
        Nodes.RenderTesselatedPolygon(true, pNorm, 1)
      else
        Nodes.RenderTesselatedPolygon(true, pNorm, Division);
    end;
    // tessellate bottom polygon
    if ppBottom in FParts then
    begin
      if Assigned(pNorm) then
        NegateVector(Normal);
      if SplineMode = lsmLines then
        Nodes.RenderTesselatedPolygon(true, pNorm, 1, true)
      else
        Nodes.RenderTesselatedPolygon(true, pNorm, Division, true);
    end;
  end;
end;


//-------------------------------------------------------------

// ------------------
// ------------------ TgxTeapot ------------------
// ------------------

constructor TgxTeapot.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGrid := 5;
end;

function TgxTeapot.AxisAlignedDimensionsUnscaled: TVector4f;
begin
  SetVector(Result, 0.55, 0.25, 0.35);
end;

procedure TgxTeapot.BuildList(var rci: TgxRenderContextInfo);

const
  PatchData: array[0..9, 0..15] of Integer =
    ((102, 103, 104, 105, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15), // rim
    (12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27), // body
    (24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40), // body
    (96, 96, 96, 96, 97, 98, 99, 100, 101, 101, 101, 101, 0, 1, 2, 3), // lid
    (0, 1, 2, 3, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117), // lid
    (118, 118, 118, 118, 124, 122, 119, 121, 123, 126, 125, 120, 40, 39, 38, 37), // bottom
    (41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56), // handle
    (53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 28, 65, 66, 67), // handle
    (68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83), // spout
    (80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95)); // spout

  CPData: array[0..126, 0..2] of Single =
    ((0.2, 0, 2.7), (0.2, -0.112, 2.7), (0.112, -0.2, 2.7), (0, -0.2, 2.7), (1.3375, 0, 2.53125),
    (1.3375, -0.749, 2.53125), (0.749, -1.3375, 2.53125), (0, -1.3375, 2.53125),
    (1.4375, 0, 2.53125), (1.4375, -0.805, 2.53125), (0.805, -1.4375, 2.53125),
    (0, -1.4375, 2.53125), (1.5, 0, 2.4), (1.5, -0.84, 2.4), (0.84, -1.5, 2.4), (0, -1.5, 2.4),
    (1.75, 0, 1.875), (1.75, -0.98, 1.875), (0.98, -1.75, 1.875), (0, -1.75, 1.875), (2, 0, 1.35),
    (2, -1.12, 1.35), (1.12, -2, 1.35), (0, -2, 1.35), (2, 0, 0.9), (2, -1.12, 0.9), (1.12, -2, 0.9),
    (0, -2, 0.9), (-2, 0, 0.9), (2, 0, 0.45), (2, -1.12, 0.45), (1.12, -2, 0.45), (0, -2, 0.45),
    (1.5, 0, 0.225), (1.5, -0.84, 0.225), (0.84, -1.5, 0.225), (0, -1.5, 0.225), (1.5, 0, 0.15),
    (1.5, -0.84, 0.15), (0.84, -1.5, 0.15), (0, -1.5, 0.15), (-1.6, 0, 2.025), (-1.6, -0.3, 2.025),
    (-1.5, -0.3, 2.25), (-1.5, 0, 2.25), (-2.3, 0, 2.025), (-2.3, -0.3, 2.025), (-2.5, -0.3, 2.25),
    (-2.5, 0, 2.25), (-2.7, 0, 2.025), (-2.7, -0.3, 2.025), (-3, -0.3, 2.25), (-3, 0, 2.25),
    (-2.7, 0, 1.8), (-2.7, -0.3, 1.8), (-3, -0.3, 1.8), (-3, 0, 1.8), (-2.7, 0, 1.575),
    (-2.7, -0.3, 1.575), (-3, -0.3, 1.35), (-3, 0, 1.35), (-2.5, 0, 1.125), (-2.5, -0.3, 1.125),
    (-2.65, -0.3, 0.9375), (-2.65, 0, 0.9375), (-2, -0.3, 0.9), (-1.9, -0.3, 0.6), (-1.9, 0, 0.6),
    (1.7, 0, 1.425), (1.7, -0.66, 1.425), (1.7, -0.66, 0.6), (1.7, 0, 0.6), (2.6, 0, 1.425),
    (2.6, -0.66, 1.425), (3.1, -0.66, 0.825), (3.1, 0, 0.825), (2.3, 0, 2.1), (2.3, -0.25, 2.1),
    (2.4, -0.25, 2.025), (2.4, 0, 2.025), (2.7, 0, 2.4), (2.7, -0.25, 2.4), (3.3, -0.25, 2.4),
    (3.3, 0, 2.4), (2.8, 0, 2.475), (2.8, -0.25, 2.475), (3.525, -0.25, 2.49375),
    (3.525, 0, 2.49375), (2.9, 0, 2.475), (2.9, -0.15, 2.475), (3.45, -0.15, 2.5125),
    (3.45, 0, 2.5125), (2.8, 0, 2.4), (2.8, -0.15, 2.4), (3.2, 0.15, 2.4), (3.2, 0, 2.4),
    (0, 0, 3.15), (0.8, 0, 3.15), (0.8, -0.45, 3.15), (0.45, -0.8, 3.15), (0, -0.8, 3.15),
    (0, 0, 2.85), (1.4, 0, 2.4), (1.4, -0.784, 2.4), (0.784, -1.4, 2.4), (0, -1.4, 2.4),
    (0.4, 0, 2.55), (0.4, -0.224, 2.55), (0.224, -0.4, 2.55), (0, -0.4, 2.55), (1.3, 0, 2.55),
    (1.3, -0.728, 2.55), (0.728, -1.3, 2.55), (0, -1.3, 2.55), (1.3, 0, 2.4), (1.3, -0.728, 2.4),
    (0.728, -1.3, 2.4), (0, -1.3, 2.4), (0, 0, 0), (1.425, -0.798, 0), (1.5, 0, 0.075), (1.425, 0, 0),
    (0.798, -1.425, 0), (0, -1.5, 0.075), (0, -1.425, 0), (1.5, -0.84, 0.075), (0.84, -1.5, 0.075));

  Tex: array[0..1, 0..1, 0..1] of Single =
    (((0, 0), (1, 0)), ((0, 1), (1, 1)));

var
  P, Q, R, S: array[0..3, 0..3, 0..2] of Single;
  I, J, K, L, GRD: Integer;
begin
  if FGrid < 2 then
    FGrid := 2;
  GRD := FGrid;

  rci.gxStates.InvertFrontFace;
  glEnable(GL_AUTO_NORMAL);
  glEnable(GL_MAP2_VERTEX_3);
  glEnable(GL_MAP2_TEXTURE_COORD_2);
  for I := 0 to 9 do
  begin
    for J := 0 to 3 do
    begin
      for K := 0 to 3 do
      begin
        for L := 0 to 2 do
        begin
          P[J, K, L] := CPData[PatchData[I, J * 4 + K], L];
          Q[J, K, L] := CPData[PatchData[I, J * 4 + (3 - K)], L];
          if L = 1 then
            Q[J, K, L] := -Q[J, K, L];
          if I < 6 then
          begin
            R[J, K, L] := CPData[PatchData[I, J * 4 + (3 - K)], L];
            if L = 0 then
              R[J, K, L] := -R[J, K, L];
            S[J, K, L] := CPData[PatchData[I, J * 4 + K], L];
            if L < 2 then
              S[J, K, L] := -S[J, K, L];
          end;
        end;
      end;
    end;
    glMapGrid2f(GRD, 0, 1, GRD, 0, 1);
    glMap2f(GL_MAP2_TEXTURE_COORD_2, 0, 1, 2, 2, 0, 1, 4, 2, @Tex[0, 0, 0]);
    glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, @P[0, 0, 0]);
    glEvalMesh2(GL_FILL, 0, GRD, 0, GRD);
    glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, @Q[0, 0, 0]);
    glEvalMesh2(GL_FILL, 0, GRD, 0, GRD);
    if I < 6 then
    begin
      glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, @R[0, 0, 0]);
      glEvalMesh2(GL_FILL, 0, GRD, 0, GRD);
      glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, @S[0, 0, 0]);
      glEvalMesh2(GL_FILL, 0, GRD, 0, GRD);
    end;
  end;
  glDisable(GL_AUTO_NORMAL);
  glDisable(GL_MAP2_VERTEX_3);
  glDisable(GL_MAP2_TEXTURE_COORD_2);
  rci.gxStates.InvertFrontFace;
end;

procedure TgxTeapot.DoRender(var ARci: TgxRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
const
  M: TMatrix4f = (
  X:(X:0.150000005960464; Y:0; Z:0; W:0);
  Y:(X:0; Y:-6.55670850946422e-09; Z:-0.150000005960464; W:0);
  Z:(X:0; Y:0.150000005960464; Z:-6.55670850946422e-09; W:0);
  W:(X:0; Y:1.63917712736605e-09; Z:0.0375000014901161; W:1));
begin
  // start rendering self
  if ARenderSelf then
  begin
    with ARci.PipelineTransformation do
      SetModelMatrix(MatrixMultiply(M, ModelMatrix^));
    if ARci.ignoreMaterials then
      if (osDirectDraw in ObjectStyle) or ARci.amalgamating then
        BuildList(ARci)
      else
        ARci.gxStates.CallList(GetHandle(ARci))
    else
    begin
      Material.Apply(ARci);
      repeat
        if (osDirectDraw in ObjectStyle) or ARci.amalgamating then
          BuildList(ARci)
        else
          ARci.gxStates.CallList(GetHandle(ARci));
      until not Material.UnApply(ARci);
    end;
  end;
  // start rendering children (if any)
  if ARenderChildren then
    Self.RenderChildren(0, Count - 1, ARci);
end;
// -------------------------------------------------------------
initialization
// -------------------------------------------------------------

RegisterClasses([TgxDodecahedron, TgxIcosahedron, TgxHexahedron, TgxOctahedron,
  TgxTetrahedron]);
  
RegisterClasses([TgxCylinder, TgxCone, TgxTorus, TgxDisk, TgxArrowLine,
  TgxAnnulus, TgxFrustrum, TgxPolygon, TgxCapsule, TgxArrowArc, TgxTeapot]);

end.
