unit roLogger;

interface

uses
  Classes;

type
  TRoLogger = class(TThread)
  private
    { Private declarations }
  protected
    buf:TMemoryStream;
    fn:string;
    procedure Execute; override;
  public
    logdir:string;
    logged:cardinal;
    constructor Create(CreateSuspended: Boolean);
    procedure WriteLog(s:string);
    property FileName:string read fn;
  end;

implementation

uses Windows, SysUtils;

{ Important: Methods and properties of objects in VCL or CLX can only be used
  in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TRoLogger.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TRoLogger }

constructor TRoLogger.Create(CreateSuspended: Boolean);
begin
 inherited;
 buf:=TMemoryStream.Create;
 logged:=0;
end;

procedure TRoLogger.Execute;
var
 m:TMemoryStream;
 f:TFileStream;
begin
  { Place thread code here }
  //buf:=TMemoryStream.Create;

  if not(DirectoryExists(logdir)) then CreateDir(logdir);

  fn:=logdir+'\'+FormatDateTime('yyyymmdd"-"hhnnss',now)+'.RoLog';

  while not(Terminated) do
   begin

    Windows.Sleep(2000);//2 seconden?

    if buf.Size>0 then
     begin
      m:=buf;
      buf:=TMemoryStream.Create;
      m.Position:=0;

      //assert m niet meer aan in het schrijven!

      f:=nil;
      try
       if FileExists(fn) then
        begin
         f:=TFileStream.create(fn,fmOpenWrite);
         f.Position:=f.Size;
        end
       else
        f:=TFileStream.create(fn,fmCreate);
       f.CopyFrom(m,m.Size);
      finally
       if not(f=nil) then f.Free;
      end;
      m.Free;
     end;

   end;

 //assert(buf.Size=0 want juist geschreven!
 buf.Free;

end;

procedure TRoLogger.WriteLog(s:string);
var
 t:string;
begin
 t:=';'+FormatDateTime('yyyymmddhhnnss',Now)+' '+s+#13#10;
 //buf.Position:=buf.Size;
 inc(logged,length(t));
 buf.Write(t[1],length(t));
end;

end.
