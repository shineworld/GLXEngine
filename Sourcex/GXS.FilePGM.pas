//
// Graphic Scene Engine, http://glscene.org
//

unit GXS.FilePGM;

{$I Stage.Defines.inc}

interface

uses
  System.Classes, System.SysUtils,
  Winapi.OpenGL, Winapi.OpenGLext,

  GXS.Context, GXS.Graphics, Stage.TextureFormat,
  GXS.ApplicationFileIO;

type

  TgxPGMImage = class(TgxBaseImage)
  public
    class function Capabilities: TDataFileCapabilities; override;

    procedure LoadFromFile(const filename: string); override;
    procedure SaveToFile(const filename: string); override;
    procedure LoadFromStream(stream: TStream); override;
    procedure SaveToStream(stream: TStream); override;

    procedure AssignFromTexture(textureContext: TgxContext;
      const textureHandle: GLEnum; textureTarget: TgxTextureTarget;
      const CurrentFormat: Boolean; const intFormat: TgxInternalFormat);
      reintroduce;
  end;



implementation

uses
  GXS.CUDAUtility;

  // ------------------
  // ------------------ TgxPGMImage ------------------
  // ------------------

  // LoadFromFile
  //
procedure TgxPGMImage.LoadFromFile(const filename: string);
var
  w, h: Integer;
  cutBuffer: System.PSingle;
begin
  if FileExists(filename) then
  begin
    if not IsCUTILInitialized then
      if not InitCUTIL then
      begin
        EInvalidRasterFile.Create(cCUTILFailed);
        exit;
      end;
    cutBuffer := nil;
    if cutLoadPGMf(PAnsiChar(AnsiString(filename)), cutBuffer, w, h) then
    begin
      ResourceName := filename;
      UnMipmap;
      FLOD[0].Width := w;
      FLOD[0].Height := h;
      FLOD[0].Depth := 0;
      fColorFormat := GL_LUMINANCE;
      fInternalFormat := tfLUMINANCE_FLOAT32;
      fDataType := GL_FLOAT;
      fCubeMap := false;
      fTextureArray := false;
      fElementSize := GetTextureElementSize(tfLUMINANCE_FLOAT32);
      ReallocMem(fData, DataSize);
      Move(cutBuffer^, fData^, DataSize);
      cutFree(cutBuffer);
    end;
  end
  else
    raise EInvalidRasterFile.CreateFmt('File %s not found', [filename]);
end;

// SaveToFile
//
procedure TgxPGMImage.SaveToFile(const filename: string);
begin
  if not IsCUTILInitialized then
    if not InitCUTIL then
    begin
      EInvalidRasterFile.Create(cCUTILFailed);
      exit;
    end;
  if not cutSavePGMf(PAnsiChar(AnsiString(filename)), System.PSingle(fData),
    FLOD[0].Width, FLOD[0].Height) then
    raise EInvalidRasterFile.Create('Saving to file failed');
end;

procedure TgxPGMImage.LoadFromStream(stream: TStream);
begin
  Assert(false, 'Stream loading not supported');
end;

procedure TgxPGMImage.SaveToStream(stream: TStream);
begin
  Assert(false, 'Stream saving not supported');
end;

// AssignFromTexture
//
procedure TgxPGMImage.AssignFromTexture(textureContext: TgxContext;
  const textureHandle: GLEnum; textureTarget: TgxTextureTarget;
  const CurrentFormat: Boolean; const intFormat: TgxInternalFormat);
var
  oldContext: TgxContext;
  contextActivate: Boolean;
  texFormat: Cardinal;
  residentFormat: TgxInternalFormat;
  glTarget: GLEnum;
begin
  if not((textureTarget = ttTexture2D) or (textureTarget = ttTextureRect)) then
    exit;

  oldContext := CurrentVXContext;
  contextActivate := (oldContext <> textureContext);
  if contextActivate then
  begin
    if Assigned(oldContext) then
      oldContext.Deactivate;
    textureContext.Activate;
  end;
  glTarget := DecodeTextureTarget(textureTarget);

  try
    textureContext.gxStates.TextureBinding[0, textureTarget] := textureHandle;
    fLevelCount := 0;
    fCubeMap := false;
    fTextureArray := false;
    fColorFormat := GL_LUMINANCE;
    fDataType := GL_FLOAT;
    // Check level existence
    glGetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_INTERNAL_FORMAT,
      @texFormat);
    if texFormat > 1 then
    begin
      glGetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_WIDTH, @FLOD[0].Width);
      glGetTexLevelParameteriv(glTarget, 0, GL_TEXTURE_HEIGHT,
        @FLOD[0].Height);
      FLOD[0].Depth := 0;
      residentFormat := OpenGLFormatToInternalFormat(texFormat);
      if CurrentFormat then
        fInternalFormat := residentFormat
      else
        fInternalFormat := intFormat;
      Inc(fLevelCount);
    end;
    if fLevelCount > 0 then
    begin
      fElementSize := GetTextureElementSize(fColorFormat, fDataType);
      ReallocMem(fData, DataSize);
      glGetTexImage(glTarget, 0, fColorFormat, fDataType, fData);
    end
    else
      fLevelCount := 1;
    CheckOpenGLError;
  finally
    if contextActivate then
    begin
      textureContext.Deactivate;
      if Assigned(oldContext) then
        oldContext.Activate;
    end;
  end;
end;

// Capabilities
//
class function TgxPGMImage.Capabilities: TDataFileCapabilities;
begin
  Result := [dfcRead, dfcWrite];
end;

initialization

{ Register this Fileformat-Handler }
RegisterRasterFormat('pgm', 'Portable Graymap', TgxPGMImage);

end.
