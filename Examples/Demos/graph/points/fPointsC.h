//---------------------------------------------------------------------------

#ifndef fPointsCH
#define fPointsCH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ExtCtrls.hpp>
#include "GLS.BaseClasses.hpp"
#include "GLS.Cadencer.hpp"
#include "GLS.Coordinates.hpp"

#include "GLS.Objects.hpp"
#include "GLS.Scene.hpp"
#include "GLS.SceneViewer.hpp"

//---------------------------------------------------------------------------
class TFormPoints : public TForm
{
__published:	// IDE-managed Components
	TGLSceneViewer *GLSceneViewer1;
	TPanel *Panel1;
	TLabel *LabelFPS;
	TCheckBox *CBPointParams;
	TCheckBox *CBAnimate;
	TGLScene *GLScene1;
	TGLDummyCube *DummyCube1;
	TGLPoints *GLPoints1;
	TGLPoints *GLPoints2;
	TGLCamera *GLCamera1;
	TGLCadencer *GLCadencer1;
	TTimer *Timer1;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall GLCadencer1Progress(TObject *Sender, const double deltaTime, const double newTime);
	void __fastcall GLSceneViewer1MouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
	void __fastcall GLSceneViewer1MouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
	void __fastcall CBAnimateClick(TObject *Sender);
	void __fastcall CBPointParamsClick(TObject *Sender);
	void __fastcall Timer1Timer(TObject *Sender);

private:	// User declarations
    int mx,my;
public:		// User declarations
	__fastcall TFormPoints(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TFormPoints *FormPoints;
//---------------------------------------------------------------------------
#endif
