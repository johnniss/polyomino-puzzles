:Class polyDraw2D       ⍝ Drawing 2d Polyominoes

    :include polyUtil


    ∇ res←crtrad trdfn;txt;last;lng ⍝ Canonical rep of trad func nc=3.1, to fit namespace script
     
      txt←↓⎕CR trdfn
      txt[0]←⊂'∇',¯1↓txt[0]
      last←(≢txt[0])+1-⎕IO
      lng←≢txt[last]
      :If '⍝∇⍣§'≡4↑txt[last]
          txt[last]←lng↑'∇'      ⍝ Override salt mark
      :Else
          txt,⊂lng↑'∇'
      :EndIf
      txt,←⊂lng↑'='
      res←↑txt
    ∇

    ∇ new subform
      :Access Public
      :Implements Constructor
     
      guisetup subform
      mainsetup
    ∇

    ∇ guisetup subform
     
      GUInames
     
      mainform←subform makeformu(10 85 5)(2 98 2)       ⍝ Definiton of main page subform layout
      mainf←mainform.subforms[1;1]
      headf←mainform.subforms[0;1]
      botf←mainform.subforms[2;1]
     
      headLabel←headf.⎕NEW Label(⊂Caption'2D draw')
      :With headLabel
          FontObj←'ARIAL' 25 ⋄ Size←25 230 ⋄ Posn←3 500
      :EndWith
     
     ⍝ ⍝ Save + reset buts.
⍝      :With butn3←botf.⎕NEW Button(⊂Caption'Save')
⍝          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 700
⍝      :EndWith
⍝      butn3.Event←(MouseDown'Save&' 0)
     
      :With butn4←botf.⎕NEW Button(⊂Caption'Reset')
          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 760
      :EndWith
      butn4.Event←(MouseDown'Reset&')
     
      :With scriptpanel←mainf.⎕NEW Edit((Style Multi)(FieldType Char))     ⍝(VScroll ¯1)
          FontObj←'APL385 Unicode' 20 ⋄ Size←##.Size ⋄ Posn←0 0            ⍝   'ARIAL'
      :EndWith
      scriptpanel.Event←(MouseDown'shoot&')    ⍝('KeyPress' 'dummy&')  ('ContextMenu' 'dummy&')
    ∇


    ∇ mainsetup
      size←scriptpanel.Size
      lettersize←20
      min←¯1 ¯1
      pino←0
      left right←1 2
      yxpos←{min+⌊0.5+⍵÷lettersize}
      omega←(¯1+(⍳3)∘.,(⍳3))
      compass←(3 3⍴'nv' 'n ' 'nø' 'v ' 'o ' 'ø ' 'sv' 's ' 'sø')
      omegacenters←{(⊂0 0)+(⊂lettersize)×(⊂yxpos ⍵)+omega}
      dist←{(+/(⍺-⍵)*2)*0.5}
      nabo←{dif←(yxpos ⍵)+0.5-⍵÷lettersize
          (×dif)×⊃((0 1)(1 0))[⊃</|dif]}
      Reset
     
     ⍝ ⎕←size(⍴a)
     ⍝  scriptpanel.Text←↓⊃,/(show¨3 4 pvd 5 2)     ⍝' ' 'JNH was here again' 'and again'
     ⍝ scriptpanel.Text←↓10 10⍴'0123456789'
     ⍝ scriptpanel.Text←(deko[1 3 4 3 4 3 2])(deko[7 3 8 3 8 3 12])(deko[7 3 8 3 8 3 12])(deko[5 3 13 3 13 3 9])
     ⍝ scriptpanel.Text←show a
    ∇


      pvd←{⍝ Pics polyomino from base library
          ⍺←⍬
          ⍺≡⍬:(⊂⍵)⊃#.pdb.polyvoldim             ⍝ Whole vol dim
          ((⊂⍵)⊃#.pdb.polyvoldim)[,⍺]           ⍝ Multiple items of same vol dim
      }

      show2D←{⍝ Input is a simpel 2D matrix of integers. Adjecent integers of the same value are drawn as polyomino
          deko←' ┌┐─┬└│├┼┘┼┼┤┴┼'  ⍝  deko←' ┌ ┐ ─ ┬ └ │ ├ ┼ ┘ ┼ ┼ ┤ ┴ ┼'
                                  ⍝  xxxx←' 1 2 3 4 5 6 7 8 9 0 1 2 3 4'
          wtype←(0 0 0)(0 0 1)(0 1 0)(0 1 1)(0 1 2)(1 0 0)(1 0 1)(1 0 2)
          wtype,←(1 1 0)(1 1 1)(1 1 2)(1 2 0)(1 2 1)(1 2 2)(1 2 3)
     
          box←1 2×⍴⍵
          rewrap←¯1⌽¯1⊖(box+2)↑box⍴up 2\¨,⍵
          deko[{wtype⍳⊂1↓(∪⍵)⍳⍵}¨⊃{2,/[⍺]⍵}/0 1 rewrap]
      }

⍝======================== Callbacks =================================================

    ∇ shoot msg;pos                          ⍝ Call back from mouse down
     
      pos←msg[2 3]
      mousebutn←4⊃msg
     
      oc←omegacenters pos+lettersize-2 2
      distomega←oc dist¨⊂pos
      focus←⊂yxpos pos
      inside←(0<0⊃⊃focus)∧(0<1⊃⊃focus)∧((0⊃⊃focus)<≢a)∧((1⊃⊃focus)<1⊃⍴a)
      :If inside
      :AndIf mousebutn=left
          :If a[omega+focus]≡3 3⍴0
              pino+←1
              (focus⊃a)←pino
          :ElseIf a[focus]=0
              distomega←1 1 1 1 0 1 1 1 1/,distomega
              mindistindex←distomega⍳⌊/,distomega
              (focus⊃a)←mindistindex⊃,a[((,omega)~⊂(0 0))+focus]
              :If a[focus]=0
                  (focus⊃a)←⊃⌈/a[((0 1)(1 0)(¯1 0)(0 ¯1))+focus]
              :EndIf
              :If a[focus]=0
                  pino+←1
                  (focus⊃a)←pino
              :EndIf
          :End
      :ElseIf mousebutn=right
          ⍝⎕DQ'scriptpanel' 'KeyPress' 'ER'
          (focus⊃a)←0
      :EndIf
      ⍝ ddx a
      scriptpanel.Text←show2D a
    ∇

    ∇ dummy msg
      ⍝ r←0
      ⎕←'hej der'msg
     ⍝  ⎕NQ'scriptpanel' 'KeyPress' 'ER'
    ∇

    ∇ Reset
      a←(¯1+⌊size÷lettersize)⍴0
      a[20 24;20 24]←1
      pino←1
      scriptpanel.Text←show2D a
    ∇
:endClass
