unit roHexTree;

interface

type

 THexTree=class(TObject)
 private
  Nodes:array[0..15] of TObject;
 public
  constructor Create;
  destructor Destroy; override;
  procedure SetValue(id:string;const value:OleVariant);
  function GetValue(id:string):OleVariant;
  procedure SetObject(id:string;const value:pointer);
  function SetObjectIfNil(id:string;const value:pointer):boolean;
  function GetObject(id:string):pointer;
  property Item[id:string]:OleVariant read GetValue write SetValue;
  property Objects[id:string]:pointer read GetObject write SetObject;
 end;

implementation

uses Variants;

type
 TSecundaryHexTree=class(TObject)
 public
  Nodes:array[0..15] of THexTree;
  Values:array[0..15] of OleVariant;
  Pointers:array[0..15] of pointer;
  constructor Create;
  destructor Destroy; override;
 end;

const
 hex:array[0..15] of char='0123456789ABCDEF';

constructor THexTree.Create;
var
 i:integer;
begin
 inherited;
 for i:=0 to 15 do Nodes[i]:=nil;
end;

destructor THexTree.Destroy;
var
 i:integer;
begin
 inherited;
 for i:=0 to 15 do if not(Nodes[i]=nil) then TSecundaryHexTree(Nodes[i]).Free;
end;

constructor TSecundaryHexTree.Create;
var
 i:integer;
begin
 inherited;
 for i:=0 to 15 do Nodes[i]:=nil;
 for i:=0 to 15 do Values[i]:=Null;
end;

destructor TSecundaryHexTree.Destroy;
var
 i:integer;
begin
 inherited;
 for i:=0 to 15 do if not(Nodes[i]=nil) then Nodes[i].Free;
 for i:=0 to 15 do Values[i]:=Null;
end;

function GetNode(base:THexTree;id:string;var b:byte):TSecundaryHexTree;
var
 ht:THexTree;
 hts:TSecundaryHexTree;
 found:boolean;
 i:integer;
begin
 ht:=base;
 hts:=nil;
 i:=1;
 found:=false;

 while not(found) do
  begin
   hts:=TSecundaryHexTree(ht.Nodes[byte(id[i]) shr 4]);
   if hts=nil then found:=true else
    begin
     b:=byte(id[i]) and $F;
     if i=length(id) then found:=true else
      begin
       ht:=hts.Nodes[b];
       if ht=nil then
        begin
         found:=true;
         hts:=nil;//force not found
        end
       else inc(i);
      end;
    end;
  end;

 Result:=hts;
end;

function THexTree.GetValue(id:string):OleVariant;
var
 hts:TSecundaryHexTree;
 b:byte;
begin
 hts:=GetNode(self,id,b);
 if hts=nil then Result:=Null else Result:=hts.Values[b];
end;

function THexTree.GetObject(id:string):pointer;
var
 hts:TSecundaryHexTree;
 b:byte;
begin
 hts:=GetNode(self,id,b);
 if hts=nil then Result:=nil else Result:=hts.Pointers[b];
end;

function SetNode(base:THexTree;id:string;var b:byte):TSecundaryHexTree;
var
 ht:THexTree;
 hts:TSecundaryHexTree;
 i:integer;
begin
 ht:=base;
 hts:=nil;
 i:=1;
 while i<=length(id) do
  begin
   b:=byte(id[i]) shr 4;
   hts:=TSecundaryHexTree(ht.Nodes[b]);
   if hts=nil then
    begin
     hts:=TSecundaryHexTree.Create;
     ht.Nodes[b]:=hts;
    end;
   b:=byte(id[i]) and $F;
   inc(i);
   if i<=length(id) then
    begin
     ht:=hts.Nodes[b];
     if ht=nil then
      begin
       ht:=THexTree.Create;
       hts.Nodes[b]:=ht;
      end;
    end;
   //else waarde zetten!
  end;
 Result:=hts;
end;

procedure THexTree.SetValue(id:string;const value:OleVariant);
var
 hts:TSecundaryHexTree;
 b:byte;
begin
 if not(id='') then
  begin
   hts:=SetNode(self,id,b);
   hts.Values[b]:=value;
  end;
 //else error?
end;

procedure THexTree.SetObject(id:string;const value:pointer);
var
 hts:TSecundaryHexTree;
 b:byte;
begin
 if not(id='') then
  begin
   hts:=SetNode(self,id,b);
   hts.Pointers[b]:=value;
  end;
 //else error?
end;

function THexTree.SetObjectIfNil(id:string;const value:pointer):boolean;
var
 hts:TSecundaryHexTree;
 b:byte;
 a:boolean;
begin
 a:=true;
 if not(id='') then
  begin
   hts:=SetNode(self,id,b);
   if hts.Pointers[b]=nil then hts.Pointers[b]:=value else a:=false;
  end
 else a:=false;
 //else error?
 Result:=a;
end;

end.
