//
// The graphics engine GLXEngine. The unit of GXScene for Delphi
//
unit GXS.TexturedHDS;

(*
   Implements a HDS, which automatically maps textures onto a parent HDS .
   This HDS links to and extracts its height data from a parent HDS. (like TgxHeightTileFile)

   The HDS also links to a TgxMaterial Library, and maps ALL textures from the
   selected Material Library onto the terrain, WITHOUT using Multitexturing.
   The position and scale of each texture is determined by the material's own
   TextureOffset and TextureScale properties.
   This makes it easy to tile many textures onto a single, continuous TgxTerrainRenderer.

   If two or more textures in the library overlap, the top texture is used.( ie.the later one in the list)

   WARNING: Only one base texture is mapped onto each terrain tile, so, make
   sure your texture edges are alligned to height tile edges, or gaps will show.
   (Of course you can still multitexture in a detail texture too.)
*)

interface

{$I Stage.Defines.inc}

uses
  System.Types,
  System.Classes,

  Stage.VectorTypes,
  GXS.Coordinates,
  GXS.HeightData,
  GXS.Material;

type
  TgxTexturedHDS = class(TgxHeightDataSource)
  private
    FOnStartPreparingData: TStartPreparingDataEvent;
    FOnMarkDirty: TMarkDirtyEvent;
    FHeightDataSource: TgxHeightDataSource;
    FMaterialLibrary: TgxMaterialLibrary;
    FWholeTilesOnly: Boolean;
    FTileSize: integer;
    FTilesPerTexture: integer;
  protected
    procedure SetHeightDataSource(val: TgxHeightDataSource);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure StartPreparingData(HeightData: TgxHeightData); override;
    procedure MarkDirty(const area: TRect); override;
  published
    property MaxPoolSize;
    property OnStartPreparingData: TStartPreparingDataEvent
      read FOnStartPreparingData write FOnStartPreparingData;
    property OnMarkDirtyEvent: TMarkDirtyEvent read FOnMarkDirty
      write FOnMarkDirty;
    property HeightDataSource: TgxHeightDataSource read FHeightDataSource
      write SetHeightDataSource;
    property MaterialLibrary: TgxMaterialLibrary read FMaterialLibrary
      write FMaterialLibrary;
    property WholeTilesOnly: Boolean read FWholeTilesOnly write FWholeTilesOnly;
    { This should match TileSize in TgxTerrainRenderer }
    property TileSize: integer read FTileSize write FTileSize;
    { This should match TilesPerTexture in TgxTerrainRenderer }
    property TilesPerTexture: integer read FTilesPerTexture
      write FTilesPerTexture;
  end;

//------------------------------------------------------
implementation
//------------------------------------------------------

// ------------------
// ------------------ TgxTexturedHDS ------------------
// ------------------

constructor TgxTexturedHDS.Create(AOwner: TComponent);
begin
  FHeightDataSource := nil;
  FMaterialLibrary := nil;
  FTileSize := 16;
  FTilesPerTexture := 1;
  inherited Create(AOwner);
end;

destructor TgxTexturedHDS.Destroy;
begin
  inherited Destroy;
end;

procedure TgxTexturedHDS.MarkDirty(const area: TRect);
begin
  inherited;
  if Assigned(FOnMarkDirty) then
    FOnMarkDirty(area);
end;

procedure TgxTexturedHDS.StartPreparingData(HeightData: TgxHeightData);
var
  HDS: TgxHeightDataSource;
  htfHD: TgxHeightData;
  MatLib: TgxMaterialLibrary;
  Mat: TgxLibMaterial;
  HD: TgxHeightData;
  MatInx: integer;
  tileL, tileR, tileT, tileB: single;
  found: Boolean;
  texL, texR, texT, texB, swp: single;
  texSize: integer;
begin
  if not Assigned(FHeightDataSource) then
  begin
    HeightData.DataState := hdsNone;
    exit;
  end;

  // ---Height Data--
  HD := HeightData;
  HD.DataType := hdtSmallInt;
  HD.Allocate(hdtSmallInt);
  HDS := self.FHeightDataSource;
  // HD.FTextureCoordinatesMode:=tcmWorld;
  htfHD := HDS.GetData(HD.XLeft, HD.YTop, HD.Size, HD.DataType);
  if htfHD.DataState = hdsNone then
  begin
    HD.DataState := hdsNone;
    exit;
  end
  else
    HD.DataState := hdsPreparing;
  Move(htfHD.SmallIntData^, HeightData.SmallIntData^, htfHD.DataSize); // NOT inverted
  // ----------------

  // ---Select the best texture from the attached material library--
  MatLib := self.FMaterialLibrary;
  if Assigned(MatLib) then
  begin
    // --Get the world coordinates of the current terrain height tile--
    texSize := FTileSize * FTilesPerTexture;
    if FWholeTilesOnly then
    begin // picks top texture that covers the WHOLE tile.
      tileL := (HD.XLeft) / texSize;
      tileT := (HD.YTop + (HD.Size - 1)) / texSize - 1;
      tileR := (HD.XLeft + (HD.Size - 1)) / texSize;
      tileB := (HD.YTop) / texSize - 1;
    end
    else
    begin // picks top texture that covers any part of the tile. If the texture si not wrapped, the rest of the tile is left blank.
      tileL := (HD.XLeft + (HD.Size - 2)) / texSize;
      tileT := (HD.YTop + 1) / texSize - 1;
      tileR := (HD.XLeft + 1) / texSize;
      tileB := (HD.YTop + (HD.Size - 2)) / texSize - 1;
    end;
    //--picks top texture that covers tile center--
      //tileL:=(HD.XLeft+(HD.Size/2))/HTFSizeX;
      //tileT:=(HD.YTop +(HD.Size/2))/HTFSizeY-1;
      //tileB:=tileT;
      //tileR:=tileL;
      //---------------------------------------------
    MatInx:=MatLib.Materials.Count;
    Mat:=nil;
    found:=false;
    while (not found) and (MatInx > 0) do
    begin
      MatInx := MatInx - 1;
      Mat := MatLib.Materials[MatInx];
      texL := -Mat.TextureOffset.X / Mat.TextureScale.X;
      texR := texL + (1 / Mat.TextureScale.X);
      texT := Mat.TextureOffset.Y / Mat.TextureScale.Y;
      texB := texT - (1 / Mat.TextureScale.Y);
      if texB > texT then
      begin
        swp := texB;
        texB := texT;
        texT := swp;
      end;
      if texL > texR then
      begin
        swp := texL;
        texL := texR;
        texR := swp;
      end;
      if (tileL >= texL) and (tileR <= texR) and (tileT <= texT) and (tileB >= texB) then
        found := true;
    end;
    if found then
      HD.MaterialName := Mat.Name;
  end;
  //---------------------------------------------------------------
  //HD.MaterialName:=self.FMaterialLibrary.Materials[15].Name;

  HDS.Release(htfHD);
  //heightData.DataState:=hdsReady;
  inherited;
end;

procedure TgxTexturedHDS.SetHeightDataSource(val:TgxHeightDataSource);
begin
  if val=self then FHeightDataSource:=nil
              else FHeightDataSource:=val;
end;

// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------

RegisterClasses([TgxTexturedHDS]);


end.
