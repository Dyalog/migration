:Namespace migrate
    ⎕ML←1 ⋄ ⎕io←1

    ∇ list←List
      list←(
          (
              Name:'APLPlusWin'
              Group:'Migrate'
              Parse:'1L -pre= -rep= -out= -covers='
              Desc:'Import APL+Win text source files'
          )
      )
    ∇

    ∇ r←lvl Help cmd
      :Select cmd
      :Case 'APLPlusWin'
          r←{⍵.Desc⌷⍨⍵.Name⍳⊂cmd}List
          r,←⊂'    ]',cmd,' <path> [-covers=<covers>] [-out=<out>] [-pre=<pre>] [-rep=<rep>]'
          r,←⊂''
          :If 0=lvl
              r,←⊂']',cmd,' -?? ⍝ for more information and examples'
          :Else ⍝ 1≤lvl
              r,←⊂'<path>  directory containing APL+Win source code files'
              r,←⊂''
              r,←⊂'-covers=  directory containing covers for APL+Win built-ins (default: ',optsDefs.covers FmtPath⍛,')'
              r,←⊂'-out=     directory for converted source code (default: <do not export workspace>)'
              r,←⊂'-pre=     prefix to prepend to names of covers for APL+Win built-ins (default: "',optsDefs.pre,'")'
              r,←⊂'-rep=     file containing replacements to me made in source code (default: ',optsDefs.rep FmtPath⍛,')'
              r,←⊂'          Each line consists of "regex%transformation" using ⎕R conventions'
              r,←⊂''
              r,←⊂'Example:'
              r,←⊂'    Import and convert, but leave code in # for saving with )SAVE or manual export (covers begin with "_" because it cannot begin names in APL+Win):'
              r,←⊂'        ]',cmd,' C:\apw\eigenval'
              r,←⊂'    Full conversion, but leave code in # for saving with )SAVE or manual export (covers in namespace "_" because it is an invalid name in APL+Win):'
              r,←⊂'        ]',cmd,' C:\apw\eigenval -out=C:\dyalog\eigenval -pre=_.'
          :EndIf
      :EndSelect
    ∇

    ∇ r←origin
      :If ×40 ⎕ATX'originCache'
          r←originCache
      :Else
          originCache←r←⊃⎕NPARTS 4⊃5179⌶⎕THIS
      :EndIf
    ∇

    ∇ r←optsDefs
      r←(
          pre:'_'
          rep:origin,'/apw_replacements.txt'
          debug:0
          covers:origin,'/covers'
          out:0
      )
    ∇

    win←'Win'≡3↑⊃# ⎕WG'APLVersion'

    FmtPath←{0≡⍵:'' ⋄ '"','"',⍨'\'@('/'∘=)⍣win∊1 ⎕NPARTS ⍵}

    ∇ r←Run(cmd opts)
      originCache←⊃⎕NPARTS ##.SourceFile
      r←(opts.⎕NS'pre' 'rep'/⍨~opts.(pre rep)∊0)APLPlusWin⊃opts.Arguments
      r←¯1↓∊r,¨⎕UCS 13
    ∇

    ∇ {log}←{opts}APLPlusWin path;fx;out;pcts;f;t;i;msg;count;Log
      ;rep;from;to;pre;vars;fns;ops;val;name;file;content;debug;reps;target;covers;ms
      ms←11 ⎕DT'Z'
      'opts'⎕NS ⍬
      opts{⎕THIS(⍵ ⎕NS ⍺).⎕NS ⍵.⎕NL ¯2}optsDefs
     
      log←0⍴⊂''
      Log←{
          0=≢⍵:_←0
          log,←⊂⍵
          ×debug:⍞←⍵,⎕UCS 13
      }
     
      Log'Starting migrating: ',path FmtPath⍛,(out≢∘0⍛/' → ',FmtPath out),' at ',⊃'%ISO%.fff"Z"'(1200⌶)1 ⎕DT'Z'
     
      #.⎕ML←3
     
      content←'#.'⎕R pre ⎕OPT'Regex' 0⊃⎕NGET rep 1
      pcts←1='%'+.=¨content
      ⎕SIGNAL(∧/pcts)↓⊂('EN' 11)('Message' ⋄ 'Invalid number of %s in ',rep FmtPath⍛,'[',(⍕⍸~pcts),']:',1↓∊{', "',⍵,'"'}¨content/⍨~pcts)
      (from to)←↓⍉↑'%'(≠⊆¨⊢)content
      msg←''
      :For f t i :InEach from to(⍳≢to)
          :Trap debug↓11 11
              {}f ⎕R t⊢''
          :Else
              msg,←'; ',('.*: '⎕R''⊢⎕DMX.Message,' ',⍕i),', "',f,'%',t,'"'
          :EndTrap
      :EndFor
      ⎕SIGNAL(×≢msg)↑⊂('EN' 11)('Message' ⋄ (2⌽msg),'in ',FmtPath rep)
     
      (from to)⊂⍛,⍨←'''[^'']*''|⍝.*' '&'
     
      Log'Loaded: ',(⍕≢from),' replacement phrases from ',FmtPath rep
     
      (vars fns)←⊃¨⎕NINFO ⎕OPT 1⊢(path,'/*.apl')∘,¨'af'
      :For file :In vars
          name←(,¨'•_‘ñ')⎕R(,¨'⎕_∆⍙')∧\⍤≠∘'-'⍛⌿2⊃⎕NPARTS file
          :Trap debug↓0 0
              val←⍎⊃⊃⎕NGET file 1
          :Else
              Log(⊃⎕DMX.DM),': Variable ',name,' from ',FmtPath file
          :EndTrap
          # ⎕VSET⊂name val
      :EndFor
      Log'Imported ',(⍕≢vars),' source variables from ',path FmtPath⍛,' → #'
      reps←0
      :For file :In fns
          content←⊃⎕NGET file 1
          reps+←+/×from ⎕S 3⊢content
          content←from ⎕R to⊢content
          fx←#.⎕FX content
          :If ⍬≡0/fx
              Log'DEFN ERROR: Function ',(∧\⍤≠∘'-'⍛⌿2⊃⎕NPARTS file),'[',(⍕fx-1),'] from ',FmtPath file
          :EndIf
      :EndFor
      Log'Imported: ',(⍕≢vars),' source functions from ',path FmtPath⍛,' → #'
      Log'Replaced: ',reps⍕⍛,' source phrases'
     
      count←+/≢¨(vars fns ops)←⊃¨⎕NINFO ⎕OPT 1⊢(covers,'/*.apl')∘,¨'afo'
      :For file :In vars
          val←⎕SE.Dyalog.Array.Deserialise⊃⎕NGET file
          name←2⊃⎕NPARTS file
          :If 'GLOBAL∆TRAP'≡name
              (3⊃¨val)←'#.'⎕R pre ⎕OPT'Regex' 0⊢3⊃¨val
          :EndIf
          # ⎕VSET⊂(pre,name)val ⍝ save target for fn/op defs
      :EndFor
     
      target←⎕VGET'#',¯1⌽-⍤⊥⍨⍤≠∘'.'⍛↓pre
      to←'&',⍨-⍤⊥⍨⍤≠∘'.'⍛↑pre
      :For file :In fns,ops
          name←2⊃⎕NPARTS file
          content←⊃⎕NGET file 1
                  ⍝ whole-word name, no -123
          content←('(*nlb:\w)',(∧\⍤≠∘'-'⍛⌿name),'(*nla:\w)')⎕R to@1⊢content
          2 target.⎕FIX content
      :EndFor
     
      Log'Imported: ',count⍕⍛,' covers from ',covers FmtPath⍛,' → ',⍕target
     
      :If 0≡out
          Log'Warning: Workspace not saved!'
      :Else
          :If 3 ⎕NDELETE out
              Log'Deleted: ',FmtPath out
          :EndIf
          Log(arrays:1 ⋄ sysVars:1)⎕SE.Link.Export # out
      :EndIf
      Log'Finished: Ran for ',(⍕1000÷⍨ms-⍨11 ⎕DT'Z'),' seconds until ',⊃'%ISO%.fff"Z"'(1200⌶)1 ⎕DT'Z'
    ∇
:EndNamespace
