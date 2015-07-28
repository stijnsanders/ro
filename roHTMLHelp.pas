unit roHTMLHelp;

interface

uses MSHTML, ActnList;

function FindStyle(WebDoc:IHTMLDocument2;const selector:WideString):IHTMLStyleSheetRule;
procedure ToggleStyle(WebDoc:IHTMLDocument2;action:TAction;selector:WideString);
procedure SetStyle(WebDoc:IHTMLDocument2;selector:WideString;value:boolean);
//bij SetStyle zelf de action regelen!
procedure StyleShown(WebDoc:IHTMLDocument2;action:TAction;selector:WideString);

implementation

function FindStyle(WebDoc:IHTMLDocument2;const selector:WideString):IHTMLStyleSheetRule;
var
 i,ss:integer;
 v:OleVariant;
 s:IHTMLStyleSheetRulesCollection;
 r:IHTMLStyleSheetRule;
begin
 r:=nil;
 ss:=0;
 while (r=nil) and (ss<WebDoc.styleSheets.length) do
  begin
   v:=ss;
   s:=(IDispatch(WebDoc.styleSheets.item(v)) as IHTMLStyleSheet).rules;
   i:=0;
   while (i<s.length) and not(s.item(i).selectorText=selector) do inc(i);
   if not(i=s.length) then r:=s.item(i);
   inc(ss);
  end;
 Result:=r;
end;

procedure ToggleStyle(WebDoc:IHTMLDocument2;action:TAction;selector:WideString);
var
 r:IHTMLStyleSheetRule;
begin
 r:=FindStyle(WebDoc,selector);
 if not(r=nil) then
  begin

   //save scrolled-down pos?
   //with (WebDoc.body as IHTMLElement2) do i:=scrollHeight-scrollTop-clientHeight;

   if r.style.display='none' then
    begin
     r.style.display:='';
     action.Checked:=true;
    end
   else
    begin
     r.style.display:='none';
     action.Checked:=false;
    end;

   //base on stored sroll down?
   with (WebDoc.body as IHTMLElement2) do
    begin
     WebDoc.parentWindow.scrollTo(scrollLeft,scrollHeight-clientHeight);
    end;

  end;
end;

procedure SetStyle(WebDoc:IHTMLDocument2;selector:WideString;value:boolean);
var
 r:IHTMLStyleSheetRule;
begin
 r:=FindStyle(WebDoc,selector);
 if not(r=nil) then
  begin

   //save scrolled-down pos?
   //with (WebDoc.body as IHTMLElement2) do i:=scrollHeight-scrollTop-clientHeight;

   if value then r.style.display:='' else r.style.display:='none';

   //base on stored sroll down?
   with (WebDoc.body as IHTMLElement2) do
    begin
     WebDoc.parentWindow.scrollTo(scrollLeft,scrollHeight-clientHeight);
    end;

  end;
end;

procedure StyleShown(WebDoc:IHTMLDocument2;action:TAction;selector:WideString);
var
 r:IHTMLStyleSheetRule;
begin
 r:=FindStyle(WebDoc,selector);
 action.Visible:=not(r=nil);
 if not(r=nil) then action.Checked:=not(r.style.display='none');
end;


end.
