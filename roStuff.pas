unit roStuff;

interface

uses SysUtils, roSock;

type
  ERoError=class(Exception)
    //nog dingen?
  end;

  TMessageTypes=(
    cmUnknown,
    cmNetwork,
    cmSystem,
    cmIrc,
    cmEvent,
    cmMotd,//alleen voor ConWin normaal
    cmError);
  TRoParsedLine=class
  private
    CheckedCTCP,WasCTCP,ParamsParsed,NickParsed:boolean;
    FNick,FHTML:string;
    Params:array of string;
    procedure ParseParams;
  public
    MessageType:TMessageTypes;
    origin,code,prefix,parameters,text,Stripped:string;
    constructor Create(const DoText:string);
    procedure Parse(const s:string);
    procedure PrepHTML;
    function NickFromOrigin:string;
    function IsCTCP:boolean;
    procedure ParseCTCP;
    function Parameter(index:integer):string;
    function GetHTML(highlighted:boolean=false;gold:boolean=false):string;
  end;
  TRoErrorLine=class(TRoParsedLine)
  public
    constructor Create(const AMsg:string;const ACode:string='');
  end;
  TRoNetworkLine=class(TRoParsedLine)
  public
    constructor Create(Socket: TTcpSocket;const AMsg:string);
  end;


const
  //images index (bij WinDock
  iiDefault=0;
  iiWeb=1;
  iiCode=2;
  iiApp=3;
  iiNetworks=4;
  iiConClosed=5;
  iiConOpen=6;
  iiConMsg=7;
  iiConHigh=8;
  iiAlpha=9;
  iiAlphaMsg=10;
  iiAlphaHigh=11;
  iiAlphaWasHigh=12;
  iiAlphaOld=13;
  iiChan=14;
  iiChanMsg=15;
  iiChanHigh=16;
  iiChanWasHigh=17;
  iiChanOld=18;
  iiChanOp=19;
  iiChanOpMsg=20;
  iiChanOpHigh=21;
  iiChanOpWasHigh=22;
  iiChanOpOld=23;
  iiDccNoCon=24;
  iiDcc=25;
  iiDccMsg=26;
  iiDccHigh=27;
  iiDccWasHigh=28;
  iiDccOld=29;

  //layout codes!
  ircBold=#2;
  ircUnderline=#31;
  ircColor=#3;
  ircInverse=#22;
  ircClear=#15;

  ircCTCP=#1;

  WhiteSpace=[' ',#9];
  CommandPrefix='/';
  CommandChars=['*','~','/','-','='];//see ConWin.DoCommand
  ChannelPrefix=['&','#','+','!'];
  UserSeparators=[',',';',' ',#9];

  //scandinavian lower case ['{','}','|','^']
  //scandinavian upper case ['[',']','\','~']

  {//deze inlezen uit 001..005?
  UserModes=['a','o','O','i','r','w','s'];
  ChannelModes=
  ['a','b','e','i','I','k','l','m','n','o','O','p','q','r','s','t','v'];
  ChannelModesParam=['b','e','i','I','k','l','m','o','O','v'];
  ChannelModesParamPersist=['k','l'];
  }

  //hextree prefixes
  htTarget='T';
  htNickList='N';
  htIdentD='D';
  htNick=';';
  htCompletion='C';

  htSetting='s';

  rotateBlockName='rotate';//span id prefix
  //rotate, misschien later options
  rotateBlockSize=25;
  rotateBlockCount=50;

  iconOldMsgCount=25;

  historyLimit=50;

resourcestring
  roErrorNoConWin='Message window not connected to a connection window';
  roErrorTargetInUse='Target already has a window connected to it';
  roErrorConnectOutOfAltNicks='Out of alternative nicks, set a nick with "/nick <nick>"';

  roClose='Exit Ro?';
  roNoDB='No database found!';
  roNoNetwork='Please select network first.';
  roDeleteItem='Delete item and all associated data?';
  roAlreadyPasting='Can''t paste, already pasting data.';

  roConnectionWinClose='Close connection?';

function SysImg(name:string;width:integer=9;height:integer=9):string;
function SysImgOrigin(origin:string):string;
function SysTimeHTML:string;

function cutNext(var src:string):string;

procedure AddFlag(var flags:string;flag:char);
procedure DelFlag(var flags:string;flag:char);
function CheckFlag(flags:string;flag:char):boolean;

function URLEncode(s:string):string;
function URLDecode(s:string):string;
function HTMLEncode(s:string;DoEMails:boolean=false):string;

function CompareTargets(t1,t2:string;strong:boolean=true):boolean;

function SinceToStr(d:TDateTime):string;

implementation

uses VBScript_RegExp_55_TLB;

function HTMLEncodeEX(s:string;DoEMails:boolean;var stripped:string):string;
var
 i:integer;
 t,u:string;
 spanBold,spanItalic,spanUnderline,spanColor:boolean;
 spanFC,spanBC:string;
 c:integer;
 procedure spanClear;
 begin
  if spanBold then begin t:=t+'</b>'; spanBold:=false; end;
  if spanItalic then begin t:=t+'</i>'; spanItalic:=false; end;
  if spanUnderline then begin t:=t+'</u>'; spanUnderline:=false; end;
  if spanColor then
   begin
    t:=t+'</span>';
    spanColor:=false;
    spanFC:='';
    spanBC:='';
   end;
 end;
 function getColor(code:integer):string;
 begin
  case code of
   -1:Result:='';
{   0:Result:='#FFFFFF';
   1:Result:='#000000';
   2:Result:='#0000C0';
   3:Result:='#00C000';
   4:Result:='#C00000';
   5:Result:='#C08000';
   6:Result:='#C000C0';
   7:Result:='#C0C000';
   8:Result:='#FFCC00';
   9:Result:='#00FF00';
   10:Result:='#00C0C0';
   11:Result:='#00FFFF';
   12:Result:='#0000FF';
   13:Result:='#FF00FF';
   14:Result:='#808080';
   15:Result:='#C0C0C0';
}

   0:Result:='#FFFFFF';
   1:Result:='#000000';
   2:Result:='#000099';
   3:Result:='#009900';
   4:Result:='#990000';
   5:Result:='#996600';
   6:Result:='#990099';
   7:Result:='#999900';
   8:Result:='#FFCC00';
   9:Result:='#00FF00';
   10:Result:='#009999';
   11:Result:='#00FFFF';
   12:Result:='#0000FF';
   13:Result:='#FF00FF';
   14:Result:='#666666';
   15:Result:='#999999';
   else Result:='';
  end;
 end;
 function nextIsNumber:boolean;
  begin
   if (i<length(s)) and (s[i+1] in ['0'..'9']) then
    begin
     inc(i);
     c:=c*10+byte(s[i])-48;
     Result:=true;
    end
   else Result:=false;
  end;
var
 re,re1:TRegExp;
 ml:IMatchCollection;
 m:IMatch;
 j,k:integer;
begin
 t:='';
 stripped:='';

 spanBold:=false;
 spanItalic:=false;
 spanUnderline:=false;
 spanColor:=false;
 spanFC:='';
 spanBC:='';

 //for i:=1 to length(s) do
 i:=1;
 while i<=length(s) do
  begin
   case s[i] of
    #0,#1,#4..#8,#11,#14,#16..#21,#23..#30:
     t:=t+'<span style="color:#8C8CC8;">['+inttostr(byte(s[i]))+']</span>';
    #12:t:=t+'<hr />';
    #13:t:=t+'<br />';
    #10:;//checken voor #13#10 combo?
    ircBold:
     begin
      //<u>'s en zo die kruisen?
      spanBold:=not(spanBold);
      if spanBold then t:=t+'<b>' else t:=t+'</b>';
     end;
    ircUnderline:
     begin
      if spanBold then t:=t+'</b>';
      spanUnderline:=not(spanUnderline);
      if spanUnderline then t:=t+'<u>' else t:=t+'</u>';
      if spanBold then t:=t+'<b>';
     end;
{
     begin
      if spanBold then t:=t+'</b>';
      if spanUnderline then t:=t+'</u>';
      spanItalic:=not(spanItalic);
      if spanItalic then t:=t+'<i>' else t:=t+'</i>';
      if spanUnderline then t:=t+'<u>';
      if spanBold then t:=t+'<b>';
     end;
}
    ircInverse:
     begin
      if spanBold then t:=t+'</b>';
      if spanUnderline then t:=t+'</u>';
      if spanItalic then t:=t+'</i>';

      if spanColor then t:=t+'</span>';
      spanColor:=true;
      spanFC:='window';
      spanBC:='windowtext';
      t:=t+'<span style="color:'+spanFC+';background-color:'+spanBC+';">';

      if spanItalic then t:=t+'<i>';
      if spanUnderline then t:=t+'<u>';
      if spanBold then t:=t+'<b>';
     end;
    ircColor:
     begin
      if spanBold then t:=t+'</b>';
      if spanUnderline then t:=t+'</u>';
      if spanItalic then t:=t+'</i>';

      if spanColor then t:=t+'</span>';
      c:=0;
      if nextIsNumber then
       begin
        nextIsNumber;
        spanFC:=getColor(c);
        spanColor:=true;
        if (i<length(s)) and (s[i+1]=',') then
         begin
          inc(i);
          c:=0;
          if nextIsNumber then
           begin
            nextIsNumber;
            spanBC:=getColor(c);
           end;
         end;
       end
      else
       begin
        spanColor:=false;
        spanFC:='';
        spanBC:='';
       end;

      if spanColor then
       begin
        t:=t+'<span style="';
        if not(spanFC='') then t:=t+'color:'+spanFC+';';
        if not(spanBC='') then t:=t+'background-color:'+spanBC+';';
        t:=t+'">';
       end;

      if spanItalic then t:=t+'<i>';
      if spanUnderline then t:=t+'<u>';
      if spanBold then t:=t+'<b>';
     end;
    #9:
     begin
      t:=t+' &nbsp;&nbsp;&nbsp;&nbsp; ';
      stripped:=stripped+' ';
     end;
    ircClear:spanClear;
    //nieuwe hier?
    else
     begin
      //enkele char replaces
      case s[i] of
       '&':t:=t+'&amp;';
       //apos?
       '"':t:=t+'&quot;';
       '<':t:=t+'&lt;';
       '>':t:=t+'&gt;';
       else t:=t+s[i];
      end;
      stripped:=stripped+s[i];
     end;
   end;
   inc(i);
  end;
 spanClear;

 //let op hier!
 //strippos zou moeten gevuld zijn met offsets in t voor de links!

 re:=TRegExp.Create(nil);
 re.IgnoreCase:=true;
 re.Global:=true;

 //links
 //:. punt hier omdat gewoon "news: " niet uit zou komen
 re.Pattern:='((http|https|mailto|ftp|news):.|www\.[-a-z0-9]+\.[a-z][a-z][a-z]?)([^\s"'')\]&<>]|&amp;)*';

 re1:=TRegExp.Create(nil);
 re1.IgnoreCase:=true;
 re1.Global:=true;
 re1.Pattern:='^www';

 ml:=re.Execute(t) as IMatchCollection;//tussen de tags
 u:='';
 j:=length(t);
 for i:=ml.Count-1 downto 0 do
  begin
   m:=ml.Item[i] as IMatch;
   k:=m.FirstIndex+1+m.Length;
   u:=copy(t,k,j-k+1)+u;//stuk er na overnemen
   if re1.Test(m.Value) then
    begin
     u:='<a href="http://'+m.Value+'" target="_blank">'+m.Value+'</a>'+u
    end
   else
    begin
     u:='<a href="'+m.Value+'" target="_blank">'+m.Value+'</a>'+u
    end;
   //nog??
   j:=m.FirstIndex;
  end;
 u:=re.Replace(copy(t,1,j),'$1')+u;//voorste stukje

 //e-mails
 if DoEMails then
  begin
   re.Pattern:='<[^>]+?>';
   re1.Pattern:='([^\s\x00-\x1F()<>@\[\],;:\\"'']+?@[-0-9a-z.]+)';

   t:=u;
   u:='';
   ml:=re.Execute(t) as IMatchCollection;//tussen de tags
   j:=1;
   for i:=0 to ml.Count-1 do
    begin
     m:=ml.Item[i] as IMatch;
     u:=u+
      re.Replace(copy(t,j,m.FirstIndex-j+1),'<a href="mailto:$1">$1</a>')+
      m.Value;
     j:=m.FirstIndex+m.Length+1;
    end;
   //stuk er na
   u:=u+re1.Replace(copy(t,j,length(t)-j+1),'<a href="mailto:$1">$1</a>');
  end;

 //spaces
 re.Pattern:='  ';
 t:=re.Replace(t,' &nbsp;');

 re.Free;
 re1.Free;
 ml:=nil;
 m:=nil;

 Result:=u;
end;

const
 hex:array[0..15] of char='0123456789ABCDEF';

function URLEncode(s:string):string;
var
 t:string;
 i:integer;
begin
 t:='';
 for i:=1 to length(s) do
  begin
   if not(s[i] in ['a'..'z','A'..'Z','0'..'9','-','_','@','*','.']) then
    t:=t+'%'+hex[byte(s[i]) shr 4]+hex[byte(s[i]) and $F]
   else t:=t+s[i];
  end;
 Result:=t;
end;

function URLDecode(s:string):string;
var
 i:integer;
 b1,b2:byte;
 t:string;
begin
 t:='';
 i:=1;
 while i<=length(s) do
  begin
   case s[i] of
    '%':
     begin
      b1:=0; inc(i); if i<=length(s) then while not(b1=16) and not(hex[b1]=s[i]) do inc(b1);
      b2:=0; inc(i); if i<=length(s) then while not(b2=16) and not(hex[b2]=s[i]) do inc(b2);
      t:=t+char((b1 shl 4) or (b2 and $F));
     end;
    '+':t:=t+' '; 
    else t:=t+s[i];
   end;
   inc(i);
  end;
 Result:=t;
end;

function HTMLEncode(s:string;DoEMails:boolean=false):string;
var
 t:string;
begin
 Result:=HTMLEncodeEx(s,DoEMails,t);
end;

function cutNext(var src:string):string;
 { --- USE THIS FUNCTION SPARINGLY ---
  anything that doesn't chuck away the first part of the string
  does enjoy preference over using cutNext
 }
var
 i:integer;
 s:string;
begin
 s:='';
 i:=1;
 while not(i>length(src)) and not(src[i]=' ') do inc(i);
 if i>length(src) then
  begin
   s:=src;
   src:='';
  end
 else
  begin
   s:=copy(src,1,i-1);
   src:=copy(src,i+1,length(src)-i);
  end;
 Result:=s;
end;

procedure AddFlag(var flags:string;flag:char);
var
 i:integer;
begin
 i:=1;
 while (i<=length(flags)) and not(flags[i]=flag) do inc(i);
 if not(i<=length(flags)) then
  begin
   //s:=s+flag;
   //alfabetisch invoegen
   i:=1;
   while (i<=length(flags)) and not(flags[i]>flag) do inc(i);
   flags:=copy(flags,1,i-1)+flag+copy(flags,i,length(flags)-i+1);
  end;
end;

procedure DelFlag(var flags:string;flag:char);
var
 i:integer;
begin
 i:=1;
 while (i<=length(flags)) and not(flags[i]=flag) do inc(i);
 if (i<=length(flags)) then
  flags:=copy(flags,1,i-1)+copy(flags,i+1,length(flags)-i);
end;

function CheckFlag(flags:string;flag:char):boolean;
var
 i:integer;
begin
 i:=1;
 while (i<=length(flags)) and not(flags[i]=flag) do inc(i);
 Result:=(i<=length(flags));
end;

function CompareTargets(t1,t2:string;strong:boolean=true):boolean;
var
 a:boolean;
begin
 //scandinavian lower case ['{','}','|','^']
 //scandinavian upper case ['[',']','\','~']

 a:=false;
 if t1=t2 then a:=true else
  if UpperCase(t1)=UpperCase(t2) then a:=true else
   if not(strong) then
    if not(t1='') and not(t2='') then
     if t1[1] in ChannelPrefix then
      begin
       if UpperCase(copy(t1,2,length(t1)-1))=UpperCase(t2) then a:=true
      end
     else
      if t2[1] in ChannelPrefix then
       begin
        if UpperCase(copy(t2,2,length(t2)-1))=UpperCase(t1) then a:=true;
       end;
 Result:=a;
end;

function SysImgOpen(name:string;width:integer;height:integer):string;
begin
 Result:='<img src="'+name+
  '" width="'+IntToStr(width)+
  '" height="'+IntToStr(height)+'" hspace="1" align="absmiddle"';
end;

function SysImg(name:string;width:integer=9;height:integer=9):string;
begin
 Result:=SysImgOpen(name,width,height)+' />';
end;

function SysImgOrigin(origin:string):string;
begin
 Result:='<a href="ro:paste?'+URLEncode(origin)+'" title="'+origin+'">'+
     SysImgOpen('square',9,9)+' border="0" /></a>';
end;

function SysTimeHTML:string;
begin
 Result:='<span class="time">'+TimeToStr(Now)+' </span>';
end;

constructor TRoParsedLine.Create(const DoText:string);
begin
 inherited Create;
 MessageType:=cmIrc;
 origin:='';
 code:='';
 prefix:='';
 parameters:='';
 text:=DoText;
 CheckedCTCP:=false;
 WasCTCP:=false;
 ParamsParsed:=false;
 Stripped:='';
end;

procedure TRoParsedLine.Parse(const s:string);
var
 i,j:integer;
 function getNext:string;
  begin
   j:=i;
   while (i<=length(s)) and not(s[i] in WhiteSpace) do inc(i);
   Result:=copy(s,j,i-j);
   inc(i);
  end;
begin
 i:=1;
 origin:='';
 code:='';
 prefix:='';
 parameters:='';
 text:='';
 MessageType:=cmUnknown;
 CheckedCTCP:=false;
 WasCTCP:=false;
 ParamsParsed:=false;
 NickParsed:=false;

 if s[1]=':' then
  begin
   inc(i);
   origin:=getNext;
  end;

 code:=getNext;

 while not(i>length(s)) and not(s[i]=':') do
  begin
   if not(parameters='') then parameters:=parameters+' ';
   parameters:=parameters+getNext;
  end;

 if not(i>length(s)) and (s[i]=':') then
  begin
   inc(i);
   text:=copy(s,i,length(s)-i+1);
  end;
end;

procedure TRoParsedLine.PrepHTML;
var
 o,p:string;
begin
 //vlag op zetten?
 o:=HTMLEncodeEx(text,true,Stripped);

 p:='';
 if not(origin='') then p:=SysImgOrigin(origin);

 if not(code='') then
  begin
   if not(p='') then p:=p+' ';
   if WasCTCP then p:=p+'CTCP:';
   p:=p+code;
  end;

 //parameters
 if not(parameters='') then
  o:='<span class="parameters">'+HTMLEncode(parameters)+' </span>'+o;

 //prefix?
 if not(prefix='') then o:=prefix+' '+o;

 if not(p='') then o:='<span class="code">'+p+' </span>'+o;

 o:=SysTimeHTML+o+'<br />';

 Fhtml:=o;//+#13#10;
end;

constructor TRoErrorLine.Create(const AMsg:string;const ACode:string='');
begin
  inherited Create(AMsg);
  MessageType:=cmError;
  if ACode<>'' then code:=ACode;
  PrepHTML;
end;

constructor TRoNetworkLine.Create(Socket:TTcpSocket;const AMsg:string);
begin
  inherited Create(AMsg);
  MessageType:=cmNetwork;
  origin:=Socket.LocalHostName+' '+Socket.LocalAddress+':'+
    IntToStr(Socket.LocalPort);
end;

function TRoParsedLine.NickFromOrigin:string;
var
 i:integer;
begin
 if not(NickParsed) then
  begin
   //nick zoeken
   i:=1;
   while (i<=length(origin)) and not(origin[i]='!') do inc(i);
   FNick:=copy(origin,1,i-1);
   NickParsed:=true;
  end;
 Result:=FNick;
end;

function TRoParsedLine.IsCTCP:boolean;
var
 a:boolean;
begin
 a:=not(text='');
 if a then a:=text[1]=ircCTCP;//and text[length(pl.text)]=ircCTCP?
 CheckedCTCP:=a;
 Result:=a;
end;

procedure TRoParsedLine.ParseCTCP;
var
 i,j:integer;
begin
 if not(CheckedCTCP) and not(IsCTCP) then
  raise Exception.Create('ParseCTCP failed because line is not CTCP command');
 i:=2;//want text[1]=ircCTCP
 while (i<=length(text)) and not(text[i] in [ircCTCP,' ']) do inc(i);
 code:=copy(text,2,i-2);
 j:=length(text)-i;
 if text[length(text)]=ircCTCP then dec(j);
 text:=copy(text,i+1,j);
 WasCTCP:=true;
end;

function TRoParsedLine.Parameter(index:integer):string;
begin
 if not(ParamsParsed) then ParseParams;
 if index>=length(Params) then Result:='' else Result:=Params[index];
end;

procedure TRoParsedLine.ParseParams;
var
 i,j,c:integer;
begin
 c:=0;
 i:=1;

 SetLength(Params,0);
 while not(i>length(parameters)) do
  begin
   j:=i;
   while not(i>length(parameters)) and not(parameters[i] in WhiteSpace) do inc(i);
   inc(c);
   SetLength(Params,c);
   Params[c-1]:=copy(parameters,j,i-j);
   inc(i);
  end;

 ParamsParsed:=true;
end;

function TRoParsedLine.GetHTML(highlighted:boolean=false;gold:boolean=false):string;
var
 o:string;
begin
 //assert(not(Fhtml='')
 //if FHTML='' then raise Exception.Create('call PrepHTML first!');
 o:=FHTML;

 if highlighted then
  if gold then
   o:='<div class="highlight1">'+o+'</div>'
  else
   o:='<div class="highlight">'+o+'</div>';

 case MessageType of
  cmNetwork:o:='<span class="network">'+o+'</span>';
  cmSystem:o:='<span class="system">'+o+'</span>';
  cmError:o:='<span class="error">'+o+'</span>';
  cmEvent:o:='<span class="event">'+o+'</span>';
  cmIrc:;
  cmMotd:;
 end;
 Result:=o;
end;

function SinceToStr(d:TDateTime):string;
var
 s:string;
 f:double;
begin
 f:=Now-d; s:=IntToStr(Trunc(f))+'d ';
 f:=Frac(f)*24; s:=s+IntToStr(Trunc(f))+'h ';
 f:=Frac(f)*60; s:=s+IntToStr(Trunc(f))+''' ';
 f:=Frac(f)*60; s:=s+IntToStr(Trunc(f))+'" ';
 Result:=DateTimeToStr(d)+' '+s;
end;

end.
