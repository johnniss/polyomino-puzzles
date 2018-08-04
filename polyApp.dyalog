:Class polyApp       ⍝  Polyomino application start page 

    :field public prevpage←0
    :field public crtxt

    ∇ new
      :Access Public 
      :Implements Constructor
     
      home solve design lab←⍳4
      pagenames←'home' 'solve' 'design' 'lab'
     
      GUIsetup
      ⍝ crtxt←⎕CR¨↓⎕NL 3.1
      activate home
    ∇

    ∇ GUIsetup
     
      homepage←⎕NEW pagesetup home
      solvepage←⎕NEW pagesetup solve
      designpage←⎕NEW pagesetup design
      labpage←⎕NEW pagesetup lab
    ∇
    
    ∇ activate page
      :Access Public
     
      (page⊃homepage solvepage designpage labpage).activatepage
    ∇
    
     ⍝======================== Class pagsetup =================================================
    
    :class pagesetup                                   
     
        :field public TabCon      ⍝ TabControl object
        :field public TabBut      ⍝ Tabbuttons
        :field public SubFrm
        :field public pageid 
        :field public appinstances 
        :field public tabclass 
        :field public prevtab←0

        ∇ new pageno
          :Access Public 
          :Implements Constructor 
         
          pageid←pageno
          tabno←0
          home solve design lab←⍳4
          appinstances←⍬ ⍬ ⍬ ⍬ ⍬
         
          :Select pageid
          :Case home
              tabclass←,⊂FrontPage
              tabtxt←'Frontpage' 'Solve a Puzzle' 'Design a Puzzle' 'Polyomino Lab'
              before←1 1 1 1 1
          :Case solve
              tabclass←FrontPage #.polyPuzzlMan4d #.polyPuzzlSolve #.testPuzzlReplay #.testPuzzlReplay4D
              tabtxt←'How to Solve' 'Solving Manually' 'Solving Automatic' 'Replay solutions' 'Show 4D' '↑Front' '↓Design' '↓↓Lab'
              before←1 0 0 0 0 1 1 1
          :Case design
              tabclass←FrontPage #.polyPuzzlDef #.polyCollect #.polySculptureing
              tabtxt←'How to Design' 'Defining a puzzle' 'Make a collection' 'Draw with cubes' '↑↑Front' '↑Solve' '↓Lab'
              before←1 0 0 0 1 1 1
          :Case lab
              tabclass←FrontPage #.polyLibrary #.polyGenerate #.polyXray
              tabtxt←'Whats in the lab' 'The Library' 'The Generator' 'The X-Ray Machine' '↑↑↑Front' '↑↑Solve' '↑Design'
              before←1 0 0 0 1 1 1
          :Else
          :EndSelect
         
          :With baseform←⎕NEW'Form'(⊂'Visible' 0)        ⍝ Form window defined
              Caption←'POLYOMINO application ' ⋄ Coord←'pixel' ⋄ Size←1150 1200 ⋄ Posn←80 650
          :EndWith
         
          TabCon←baseform.⎕NEW'TabControl'(⊂'Style' 'FlatButtons')   ⍝'Tabs')
          TabCon.TabSize←25 130 ⋄ TabCon.FontObj←'ARIAL' 18
         
          TabBut←{TabCon.⎕NEW'TabButton'(⊂'Caption'⍵)}¨tabtxt
          SubFrm←{TabCon.⎕NEW'SubForm'(⊂'TabObj'(⍵⊃TabBut))}¨⍳≢tabtxt
          TabBut.Event←{'Select' 'selecttab'⍵}¨⍳≢tabtxt
         
          appinstances[home]←⎕NEW(home⊃tabclass)((home⊃SubFrm)(pageid⊃'home' 'solve' 'design' 'lab')) ⍝ homepages init
        ∇
      
        ∇ activatepage           ⍝ First activation of page
          :Access Public 
         
          baseform.Visible←1
          mainpage←prevtab⊃TabBut
          ⎕NQ'mainpage' 'Select'prevtab
        ∇
        
        ∇ tabno selecttab msg;striptxt  ⍝ Call back from tab buttons
         
          striptxt←tabtxt~¨⊂'↑↓'     ⍝ {(~⍵∊'↑↓')/⍵}¨tabtxt   ⍝ remove ↑ and ↓
          :If ~before[tabno]
              before[tabno]←1
              prevtab←tabno
              appinstances[tabno]←⎕NEW(tabno⊃tabclass)(tabno⊃SubFrm)   ⍝ initialise sub app page
          :ElseIf pageid=home
              :If tabno>0
                  baseform.Visible←0
                  ##.activate tabno               ⍝ page jump to subapp page
              :EndIf
          :ElseIf pageid>home                     ⍝ Sub app pages
              frontpos←striptxt⍳⊂'Front'
              :If tabno≥frontpos
                  baseform.Visible←0
                  :Select tabno⊃striptxt
                  :Case 'Front' ⋄ ##.activate home
                  :Case 'Solve' ⋄ ##.activate solve
                  :Case 'Design' ⋄ ##.activate design
                  :Case 'Lab' ⋄ ##.activate lab
                  :EndSelect
              :EndIf
          :EndIf
        ∇

    :endclass  ⍝ Pagesetup 

    
     ⍝======================== Class Frontpage =================================================
    
    :Class FrontPage       ⍝  Polyomino application and subapplication start page
    
        :include #.polyFns    ⍝Util    ⍝ utilFns

        ∇ new(subform pid)
          :Access Public 
          :Implements Constructor 
         
          pageid←pid
          guisetup subform
         
          rootdir←1⊃#.pdb.roots
         
          bookmark←chapter←imageno←0
        ∇
      
        ∇ guisetup subform
         
          GUInames
         
          mainform←subform makeformu(2 10 1 75 1 10 1)(1 10 1 76 1 10 1)       ⍝ Definiton of main page subform layout
          corners←,mainform.subforms[1 5;1 5]                                    ⍝ Shorthand for the main subpanes
          mainf←mainform.subforms[3;3]
          headf←mainform.subforms[1;3]
          leftside rightside←mainform.subforms[3;1 5]
          botf←mainform.subforms[5;3]
         
          labtxt←'Polyomino app' 'Solve a Puzzle' 'Design a new Puzzle' 'Polyomino Lab'
          pageindx←('home' 'solve' 'design' 'lab')⍳⊂pageid
         
          headLabel←headf.⎕NEW Label((Caption(pageindx⊃labtxt))(Justify'Centre'))
          :With headLabel
              FontObj←'ARIAL' 50 0 ⋄ Size←55 600 ⋄ Posn←30 180 ⍝ ⋄ Justfy←'Left'   ⍝
          :EndWith
         
          :With scriptpanel←mainf.⎕NEW Edit((Style Multi)(VScroll ¯1)(FieldType Char))
              FontObj←'ARIAL' 30 ⋄ Size←##.Size ⋄ Posn←0 0
          :EndWith
          scriptpanel.Event←MouseDown'carpetup'
         
          txt←5/,⊂' '
         
          :Select pageid
          :Case 'home'
              txt,←'A polyomino is a connected figure of cubes or squares.' ' '
              txt,←'You can see 4 small polyominoes in the corners, rotate when tuched. ' ' ' ' '
              txt,←'With this app you can:' ' '
              txt,←' --  Have fun solving puzzles of polyominoes. ' ' '
              txt,←' --  Design new puzzles of your own. ' ' '
              txt,←' --  Learn more about polyominoes in the lab. ' ' ' ' ' ' '
              txt,←'For more introduction to the subject:' ' '
              txt,←'    Click somewhere on this form.' ' '
              txt,←'    Or jump directly into the fun, via the tabs at the top.' ' ' ' '
         
              index←#.pdb.baseCollections.name⍳⊂'Corners'
              idp col←↓¨(index⊃#.pdb.baseCollections).(voldimid color)
              delta←3 0            ⍝ carpet direction
              ⍝sidef.BCol←⊂250 200 200
          :Case 'solve'
              txt,←'Solving puzzles can be done:' ' '
              txt,←' -- Manually, in a 3D invironment.' ' '
              txt,←' -- Automatically, finding many, if not all solutions.' ' '
              txt,←' -- Or take a look at solutions made earlier.' ' '
              txt,←' ' ' ' '  For more info on solving, click here.' ' '
              txt,←'   Or use the tabs at the top.' ' ' ' '
         
              index←#.pdb.userCollections.name⍳⊂'Corner5678'
              idp col←2⌽¨↓¨(index⊃#.pdb.userCollections).(voldimid color)
              (leftside rightside).BCol←⊂250 200 200
              delta←0 3               ⍝ carpet direction
          :Case 'design'
              txt,←'Designing new puzzles by:' ' '
              txt,←' -- Combine a collection of pieces and a container box. ' ' '
              txt,←' -- Make a new collection of pieces.' ' '
              txt,←⊂' -- Draw with cubes in 3D, making special pieces or boxes,'
              txt,←'    or just make some abstract sculptures. ' ' '
              txt,←' ' ' ' '  For more info on design, click here.' ' '
              txt,←'  Or use the tabs at the top.' ' ' ' '
         
              index←#.pdb.userCollections.name⍳⊂'C912'
              idp col←↓¨(index⊃#.pdb.userCollections).(voldimid color)
              (leftside rightside).BCol←⊂200 250 200
              delta←3 3               ⍝ carpet direction
          :Case 'lab'
              txt,←'The polyomino laboratory:' ' '
              txt,←' -- Look into the library of polyominoes. ' ' '
              txt,←' -- Generate some new polyominoes, maybe in higher dimensions.' ' '
              txt,←' -- Take a closer look at some polyomino collections.' ' '
              txt,←' ' ' ' '  For more info on the Lab, click here.' ' '
              txt,←'  Or use the tabs at the top.' ' ' ' '
         
              index←#.pdb.userCollections.name⍳⊂'C1316'
              idp col←↓¨(index⊃#.pdb.userCollections).(voldimid color)
              (leftside rightside).BCol←⊂200 200 250
              delta←3 3               ⍝ carpet direction
          :EndSelect
         
          scriptpanel.Text←txt
         
          cornerpanes←corners{⎕NEW #.utilPane(⍺ ⍵)}¨idp,∘⊂¨col     ⍝ the four corners and their polyominoes
         
         ⍝ backward and forward butns bb
         
          carpet←botf.⎕NEW Button(⊂Style Push)
          backward←leftside.⎕NEW Button(⊂Style Push)
          forward←rightside.⎕NEW Button(⊂Style Push)
          fastbackward←botf.⎕NEW Button(⊂Style Push)
          fastforward←botf.⎕NEW Button(⊂Style Push)
          ⍝ setbookmk←botf.⎕NEW Button(⊂Style Push)
          ⍝ getbookmk←botf.⎕NEW Button(⊂Style Push)
          chapterno←botf.⎕NEW Label(⊂Caption'Ch')
          :For but ix :InEach (fastbackward backward forward fastforward chapterno carpet)(⍳6) ⍝ setbookmk getbookmk)(⍳8)
              but.FontObj←'APL385 Unicode' 20 ⋄ but.Size←30 50 ⍝ but.Posn←0(300+(ix×55)+((ix=4)×20)+((ix=5)×80)+(ix>5)×170)
              but.Caption←ix⊃('←' '<' '>' '→' 'Ch 1' '⍒⍒⍒') ⋄ but.Visible←0   ⍝  'B←' 'B')
          :EndFor
         
          backward.Posn←leftside.Mm+0 8
          forward.Posn←rightside.Ml
          chapterno.Posn←botf.Um+0 ¯52
          carpet.Posn←botf.Ur+0 ¯50
          fastbackward.Posn←botf.Um+0 ¯100
          fastforward.Posn←botf.Um+0 52
         
          backward.Event←⊂Select'nextimage&' ¯1
          forward.Event←⊂Select'nextimage&' 1
          fastbackward.Event←⊂Select'newchapter&' ¯1
          fastforward.Event←⊂Select'newchapter&' 1
          ⍝ setbookmk.Event←⊂Select'setbookmark&'
          ⍝ getbookmk.Event←⊂Select'gotobookmark&'
          carpet.Event←⊂Select'carpetdown'
         
          imagenames←{¯7↑'00',(⍕⍵+1),'.jpg'}¨
          imagenames1←{¯8↑'00',(⍕⍵+1),'.jpeg'}¨
        ∇
    
     ⍝   ∇ gotochapter no   ⍝ gotochapter called from polyTab
⍝          :Access Public
⍝          setbookmark
⍝          chapter←⊃no+3
⍝          imageno←0
⍝          scriptpanel.Visible←0
⍝          (fastbackward backward forward fastforward chapterno carpet).Visible←1   ⍝setbookmk getbookmk
⍝          0 newchapter 0
⍝        ∇
 
   ⍝======================== Callbacks =================================================       
      
        ∇ carpetup;size
          0 newchapter 0
          size←scriptpanel.Size
          :For i :In ⍳⊃⌊size÷3
              scriptpanel.Size-←delta
              ⎕DL 0.005
          :EndFor
          scriptpanel.Visible←0
          (fastbackward backward forward fastforward chapterno carpet).Visible←1   ⍝ setbookmk getbookmk⍝
          0 nextimage 0
        ∇

        ∇ carpetdown;size
          0 newchapter 0
          scriptpanel.Visible←1
          size←mainf.Size
          :For i :In ⍳⊃⌊size÷3
              scriptpanel.Size+←delta
              ⎕DL 0.005
          :EndFor
          (fastbackward backward forward fastforward chapterno carpet).Visible←0    ⍝ setbookmk getbookmk
        ∇
            
     ⍝   ∇ setbookmark
⍝          bookmark←chapter imageno
⍝        ∇
⍝    
⍝        ∇ gotobookmark
⍝          chapter imageno←bookmark
⍝          0 newchapter 0
⍝        ∇
   
        ∇ dir newchapter msg
         
          chapter+←dir
          chapter⌈←1
          chapter⌊←5
         
          chapterno.Caption←'Ch ',⍕chapter
         
          :Select pageid chapter
         
          :Case 'home' 1
              subdir←'Puzzle Eksamples\Samples.'
              images←imagenames1⍳3
          :Case 'home' 2
              subdir←'Random\'
              images←⊂'Sloane 49430.png'
              images,←⊂'DSC_2096.JPG'
              images,←⊂'puzzle example 1.001.jpg'
          :Case 'home' 3
              subdir←'Code overview\theCode.'
              images←imagenames1⍳1
          :Case 'home' 4
              subdir←'Me myself I\Myself.'
              images←imagenames1⍳2
         
          :Case 'solve' 1
              subdir←'Solving manually\Solvingman.'
              images←imagenames1⍳1
          :Case 'solve' 2
              subdir←'Solving A\Solving A.'
              images←imagenames⍳1
         
          :Case 'design' 1
              subdir←'Definition\Definition.'
              images←imagenames⍳1
          :Case 'design' 2
              subdir←'Collect\Collect.'
              images←imagenames⍳1
          :Case 'design' 3
              subdir←'Drawing 3D sculptures\Drawing 3D sculptures.'
              images←imagenames⍳1
         
          :Case 'lab' 1
              subdir←'Library\Library.'
              images←imagenames⍳3
          :Case 'lab' 2
              subdir←'Generator\Generator.'
              images←imagenames⍳1
          :Case 'lab' 3
              subdir←'X-ray\X-ray.'
              images←imagenames⍳1
          :Else
         
          :EndSelect
         
          imageno×←dir=0          ⍝ reset or beware image no, depending on dir
          0 nextimage 0
        ∇
    
        ∇ dir nextimage msg
         
          imageno+←dir
          imageno⌈←0
          imageno⌊←¯1+≢images
         
          backward.Visible←imageno>0
          forward.Visible←imageno<¯1+≢images
         
          img←⎕NEW Bitmap(⊂File(rootdir,subdir,imageno⊃images))
          mainf.Picture←'img' 3   ⍝ 2 gives whole picture in bad quality
        ∇
    
    :endClass  ⍝ Frontpage       
             

:endClass ⍝ polyApp
