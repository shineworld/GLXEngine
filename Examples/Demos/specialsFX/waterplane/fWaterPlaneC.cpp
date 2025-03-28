//---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>

#pragma hdrstop

#include "fWaterPlaneC.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "GLSL.UserShader"
#pragma resource "*.dfm"

TFormWaterPlane *FormWaterPlane;

void TFormWaterPlane::ClickWater(int x, int y)
{
  TGLVector ip;
  // create a ripple in the pond on a right-mousebutton click
  GLSceneViewer1->Buffer->
    ScreenVectorIntersectWithPlaneXZ(VectorMake
                                     (x, GLSceneViewer1->Height - y, 0, 0),
                                     GLWaterPlane1->Position->Y, ip);
  GLWaterPlane1->CreateRippleAtWorldPos(ip);
}

//---------------------------------------------------------------------------
__fastcall TFormWaterPlane::TFormWaterPlane(TComponent * Owner):TForm(Owner)
{
  TFileName Path = GetCurrentAssetPath();
  SetCurrentDir(Path  + "\\texture");
  GLWaterPlane1->Mask->LoadFromFile("basinMask.bmp");
  GLHeightField1->Material->Texture->Image->LoadFromFile("clover.jpg");

  SetCurrentDir(Path  + "\\cubemap");

  // Load the cube map which is used both for environment and as reflection texture
  TGLTexture *t = GLMaterialLibrary1->Materials->Items[0]->Material->Texture;
  t->ImageClassName = __classid(TGLCubeMapImage)->ClassName();
  TGLCubeMapImage *img = (TGLCubeMapImage *) t->Image;
  // Load all 6 texture map components of the cube map
  // The 'PX', 'NX', etc. refer to 'positive X', 'negative X', etc.
  // and follow the RenderMan specs/conventions
  img->Picture[CmtPZ]->LoadFromFile("cm_back.jpg");
  img->Picture[CmtPX]->LoadFromFile("cm_left.jpg");
  img->Picture[CmtNX]->LoadFromFile("cm_right.jpg");
  img->Picture[CmtPY]->LoadFromFile("cm_top.jpg");
  img->Picture[CmtNY]->LoadFromFile("cm_bottom.jpg");
  img->Picture[CmtNZ]->LoadFromFile("cm_front.jpg");

}

//---------------------------------------------------------------------------

void __fastcall TFormWaterPlane::GLSceneViewer1MouseDown(TObject * Sender,
                                                TMouseButton Button,
                                                TShiftState Shift, int X, int Y)
{
  mx = X;
  my = Y;
  if(Shift.Contains(ssRight))
    ClickWater(X, Y);
}

//---------------------------------------------------------------------------

void __fastcall TFormWaterPlane::GLSceneViewer1MouseMove(TObject * Sender,
                                                TShiftState Shift, int X, int Y)
{
  if(Shift.Contains(ssLeft))
  {
    GLCamera1->MoveAroundTarget(my - Y, mx - X);
    // pseudo-fresnel
    TGLMaterial *m = GLMaterialLibrary1->LibMaterialByName("CubeMap")->Material;
    m->FrontProperties->Diffuse->Alpha =
      0.3 + 0.5 * sqrt(1 -
                       GLCamera1->Position->Y / GLCamera1->DistanceToTarget());
  }
  else if(Shift.Contains(ssRight))
    ClickWater(X, Y);
  mx = X;
  my = Y;
}

//---------------------------------------------------------------------------

void __fastcall TFormWaterPlane::GLUserShader1DoApply(TObject * Sender,
                                             TGLRenderContextInfo & rci)
{
  // Here is the shader trick: the same cubemap is used in reflection mode
  // for the pond, and in normal mode for the environment sphere
  // Our basic user shader takes care of that.
  int cubeMapMode;
  if(reflectionToggle)
  {
    cubeMapMode = GL_REFLECTION_MAP_ARB;
    rci.GLStates->SetGLState(stBlend);
  }
  else
  {
    cubeMapMode = GL_NORMAL_MAP_ARB;
    rci.GLStates->UnSetGLState(stBlend);
  }

  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, cubeMapMode);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, cubeMapMode);
  glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, cubeMapMode);

  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

//---------------------------------------------------------------------------

void __fastcall TFormWaterPlane::GLUserShader1DoUnApply(TObject * Sender, int Pass,
											   TGLRenderContextInfo & rci,
											   bool & Continue)
{
  rci.GLStates->UnSetGLState(stBlend);
}

//---------------------------------------------------------------------------

void __fastcall TFormWaterPlane::GLSceneViewer1BeforeRender(TObject * Sender)
{
  reflectionToggle = false;     // toggle for environment sphere
}

//---------------------------------------------------------------------------

void __fastcall TFormWaterPlane::GLDirectOpenGL1Render(TObject * Sender,
											  TGLRenderContextInfo & rci)
{
  reflectionToggle = true;      // toggle for pond/water plane
}

//---------------------------------------------------------------------------


void __fastcall TFormWaterPlane::GLCadencer1Progress(TObject * Sender,
                                            const double deltaTime,
                                            const double newTime)
{
  GLSceneViewer1->Invalidate();
}

//---------------------------------------------------------------------------

void __fastcall TFormWaterPlane::GLHeightField1GetHeight(const float x,
                                                const float y, float &z,
                                                TVector4f & color,
                                                TTexPoint & texPoint)
{
  z = 0.5 -
    (GLWaterPlane1->Mask->Bitmap->Canvas->
     Pixels[Int(x + 64)][Int(y + 64)] & 0xFF) / 255;
}

//---------------------------------------------------------------------------

