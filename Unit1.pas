unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Types3D,
  System.Math.Vectors, FMX.Objects3D, FMX.Controls3D, FMX.MaterialSources,
  FMX.Viewport3D, FMX.Ani, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, Data.DB,
  FireDAC.Comp.Client, FMX.Layers3D,FMX.Utils, FMX.Objects;

type
  TForm1 = class(TForm)
    Viewport3D1: TViewport3D;
    LightMaterialSource1: TLightMaterialSource;
    LightMaterialSource2: TLightMaterialSource;
    Light1: TLight;
    Dummy1: TDummy;
    StrokeCube1: TStrokeCube;
    RoundCube1: TRoundCube;
    Sphere1: TSphere;
    FloatAnimation1: TFloatAnimation;
    FDConnection1: TFDConnection;
    ColorKeyAnimation1: TColorKeyAnimation;
    Text1: TText;
    procedure FormCreate(Sender: TObject);
    procedure Dummy1Render(Sender: TObject; Context: TContext3D);
    procedure FloatAnimation1Finish(Sender: TObject);
    procedure FloatAnimation1Process(Sender: TObject);
    procedure RoundCube2Render(Sender: TObject; Context: TContext3D);
    procedure RoundCube1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
    procedure RoundCube1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single; RayPos, RayDir: TVector3D);
    procedure Sphere1Render(Sender: TObject; Context: TContext3D);
  private
    { Private declarations }
  public
    { Public declarations }
    Speed:Single;
    Punkte:TPoint3D;
    procedure MoveBall;
    procedure NextLevel;
    function SizeOf3D(const a3DObj:TControl3D):TPoint3D;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Dummy1Render(Sender: TObject; Context: TContext3D);
begin
//   Context.SetCameraAngleOfView(0.01);
//   with Dummy1.Scale  do   Point:=Point3D( 1,1,1) *0.01/45;
end;

procedure TForm1.FloatAnimation1Finish(Sender: TObject);
begin
NextLevel;
end;

procedure TForm1.FloatAnimation1Process(Sender: TObject);
begin
 MoveBall;
end;

procedure TForm1.FormCreate(Sender: TObject);
var V: IViewport3D;
begin

Viewport3D1.UsingDesignCamera:=True;
V:=Viewport3D1;
with TDummy(V.CurrentCamera.Parent) do    ResetRotationAngle;

Speed:=0.15;
Punkte:=NullPoint3D;
Sphere1.Position.DefaultValue:=Point3D(-0.65,-1,0);
RoundCube1.AutoCapture:=True;//maus ile kuuyu kaydýrýrken mause kutudan çýksa bile kaydýrýr
RandSeed:=23;//random fonksiyonunu güzelleþtirmek için kullanýlýr
NextLevel;

end;

procedure TForm1.MoveBall;
Var D,M,P:TPoint3D;
A,S:Integer;
R:TRoundCube;
begin
D:=Sphere1.Position.DefaultValue;
P:=Dummy1.AbsoluteToLocal3d(Sphere1.AbsolutePosition);
M:=(SizeOf3D(Dummy1)-SizeOf3D(Sphere1))*0.5;
P:=P+D.Normalize*Speed;

if((P.X>M.X) And (D.X>0)) Or ((P.X<-M.X) And (D.X <0))
  Then begin
  S:=1;
  if D.Y<0 then S:=-1;
  if Abs(D.Normalize.Y*180) <15 then D.Y:=S;  //Top hep yatay olursa sonsua gider  hep yatay olursa asagi kaysin
  D.X:=-D.X;
  end;


if((P.Y>M.Y) And (D.Y>0)) Or ((P.Y<-M.Y) And (D.Y <0))
then begin
D.Y:=-D.Y;
if P.Y >M.Y then Speed:=0;  //top aþaðý çarpýnca hýz sýfýra insin
end;




D.Z:=0;
Punkte.Z:=0;
With Dummy1
 do for A:=ChildrenCount-1 DownTo 0
do begin
	if Not (Children[A] is TRoundCube) then Continue;
	R:=TRoundCube(Children[a]);
	if R.Tag <0   //çarpan blok aþaðýda tag ý -1 oluyodu burada da onu siliyolar
	then begin
		if Speed <> 0 then Punkte.X:=Punkte.X+1;
		RemoveObject(R);
		FreeAndNil(R);
		end
	else if R.Tag=0 then Punkte.Z:=Punkte.Z+1;
	end;



with Sphere1.Position  do Point:=Point+D.Normalize*Speed;
Sphere1.Position.DefaultValue:=D;

Text1.Text:='Score '+IntToStr(Trunc(Punkte.X))+'Level '+IntToStr(Trunc(Punkte.Y))+'Blocks '+IntToStr(Trunc(Punkte.Z));


if (Punkte.Z <1) Or (Speed=0) then FloatAnimation1.StopAtCurrent;
end;


procedure TForm1.NextLevel;
Var
Z,S:TPoint3D;
A,B,C,E:Integer;
R:TRoundCube;
Y,X,F,L:Single;

begin

With Dummy1
do for A:=ChildrenCount-1 DownTo 0
  do begin
    if Not (Children[A] is TRoundCube) then Continue;
    R:=TRoundCube(Children[A]);
    if R.Tag < 1 then
    begin
    RemoveObject(R);
    FreeAndNil(R);
  end;
end;



if Speed < 0.15
then begin
	Punkte:=NullPoint3D;
	RandSeed:=23;
	Speed:=0.15
end;

if Speed>0.55 Then Speed:=Speed+0.1;
//Speed:=0.15;


Sphere1.Position.Point:=Point3D(8,3,0);
Sphere1.Position.DefaultValue:=Point3D(-0.65,-1,0);


Y:=Dummy1.Height * -0.5 +2;
C:=2+Random(4);
F:=0.5;


for A:=1 To C
do begin
    Z:=Point3D(1+Random *2,0.5+Random * 0.5 ,0.5+Random * 0.5);
    E:=Trunc(Dummy1.Width /(Z.X+F));
    L:=(E*Z.X)+((E-1)*F);
    L:=(Dummy1.Width-L)*0.5;
    X:=(Dummy1.Width* -0.5)+(L+Z.X*0.5);
    S:=Point3D(X,Y,0);
    for B:=0 to E-1
        do begin
        R:=TRoundCube.Create(Nil);
        R.MaterialSource:=LightMaterialSource2;
        R.SetSize(Z.X,Z.Y,Z.Z);
        Dummy1.AddObject(R);
        R.Position.Point:=S;
        R.Tag:=0;
        S:=S+Point3D(F+Z.X,0,0);
        R.OnRender:=RoundCube2Render;
        end;
    Y:=Y+F+Z.Y;
end;


Punkte.Y:=Punkte.Y+1;
FloatAnimation1.Start;
end;


procedure TForm1.RoundCube1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
begin

if ssLeft in Shift
then With TControl3D(Sender).Position
do DefaultValue:=Point-(RayDir*RayPos.Length)*Point3D(1,0,0);

end;

procedure TForm1.RoundCube1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single; RayPos, RayDir: TVector3D);
begin
ViewPort3D1.BeginUpdate;
if ssLeft in Shift
then With TControl3D(Sender).Position
do Point:=DefaultValue+(RayDir*RayPos.Length)*Point3D(1,0,0);
ViewPort3D1.EndUpdate
end;

procedure TForm1.RoundCube2Render(Sender: TObject; Context: TContext3D);
Var
K:TRoundCube;
P,Z,D,R,M:TPoint3D;
C:TAlphaColor;

begin

K:=TRoundCube(Sender);

With K
    do begin
    P:=AbsoluteToLocal3D(Sphere1.AbsolutePosition);
    Z:=Point3D(1/Width,1/Height,1/Depth);
    end;

R:=SizeOf3D(K);
M:=(R+SizeOf3D(Sphere1))*0.5;


if K.Tag=0
then begin
C:=Vector3DToColor(K.Position.Point.Normalize *20);  //rüst kurularýn renk random gelsin
LightMaterialSource2.Diffuse:=C;

if P.Length <5
    then begin
    //C:=TAlphaColors.Yellow;    //üst kutularýn renk sarý olsun
    Context.DrawLine(NullPoint3D,P*Z,1,C);
    Context.DrawCube(NullPoint3D,(R+P *Speed)*Z,1,C);
    end;
end;

if((Abs(P.X)<M.X) And (Abs(P.Y)<M.Y))
//top üstteki bloklara çarparsa
then begin
//FloatAnimation1.StopAtCurrent;

if K.Tag=0  //çarptýðý  kutular silinsin
then begin
K.Tag:=-1;
ColorKeyAnimation1.Start;// çarptýðýnda ekran sarý olsun
end;

D:=Sphere1.Position.Point-K.Position.Point;
Sphere1.Position.DefaultValue:=D;

end;

end;

function TForm1.SizeOf3D(const a3DObj: TControl3D): TPoint3D;
//bu form un size deðiþince çalýþýyor
begin
Result:=NullPoint3D;
if a3DObj<>Nil  then With a3DObj  do Result:=Point3D (Width,Height,Depth);

end;

procedure TForm1.Sphere1Render(Sender: TObject; Context: TContext3D);
begin

//topun gideceði yere kýrmýzý çizgi varya o
With Sphere1
do Context.DrawLine(NullPoint3D, Position.DefaultValue.Normalize * Point3D(1/Width,1/Height,1/Depth) * 5,1,TAlphaColors.Red);

end;







end.

