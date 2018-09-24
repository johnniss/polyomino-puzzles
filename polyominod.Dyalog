:Class polyominod    ⍝ Defines a single polyomino for a stage setup


    :Field Public polyomino                                        ⍝ Polyomino in adress representation
    :field Public polycols                                         ⍝ Color of each polygon
    :field Public filcol                                           ⍝ Fill colors
    :field Public theta                                            ⍝ Turning angel 1 in perspective  
    :field Public phi                                              ⍝ Turning angel 2 in perspective
    :field Public R 
    :field Public shift←0                                          ⍝ Radius in perspective ball
    :field Public vol                                              ⍝ Turning angel 1 in perspective  
    :field Public dim                                              ⍝ Turning angel 2 in perspective
    :field Public index←⍬                                                    
    :field Public polygons                                         ⍝  Polygons ready to draw  
    :field Public polytrack                                        ⍝ Faces in terms of polyomino parts 
    :field Public polyid←0
    :field Public polyfaces                                        ⍝ ok 4   
    :field Public rotfaces
    :field Public projfaces
    :field Public tracklist
    :field Public facelist
    :field Public colorlist
    :field Public cellcolors 
    :field Public selected←0                                 
    :Field Public dimensions                                       ⍝ Dimensins of polyomino envelope⍝    :Field Public polyomino                                        ⍝ Polyomino in adress representation
    :Field Public polylines                                         ⍝ Polygons of polyomino faces
    :Field Public yellowcells←⍬
    
⍝============================== Constructors ==============================                                         

    ∇ knownpoly(volx dimx no)                         ⍝ Known polyomino
      :Access Public
      :Implements Constructor
      vol dim index←volx dimx no
      polyomino←3 adrlift⊃index #.polyFns.pvd vol dim           ⍝ Pick polyomino from database
      ⍝polyid←0
      polysetup                                                   ⍝ Setup the polygons and their colors
    ∇
   
    ∇ knownpolywithcolor(volx dimx no fcol)                ⍝ Known polyomino
      :Access Public
      :Implements Constructor
      vol dim index←volx dimx no
      polyomino←3 adrlift⊃index #.polyFns.pvd vol dim           ⍝ Pick polyomino from database
      cellcolors←(⊃⍴polyomino)⍴0
      ⍝polyid←0
      filcol←fcol
      R theta phi←25 60 45                                         ⍝ Initialize perspective
      adjust                                                     ⍝ Setup the polygons and their colors
    ∇

    ∇ new(poly)                                                   ⍝ Unknown polyomino or simuli
      :Access Public
      :Implements Constructor 
      polyomino←3 adrlift poly
      vol dim←⍴polyomino
      ⍝polyid←0
      polysetup                                                    ⍝ Setup the polygons and their colors
    ∇
    
    ∇ newwithcolor(poly fcol)                                    ⍝ makes a polyomino with given color
      :Access Public
      :Implements Constructor
      ⍝polyid←0
      polyomino←3 adrlift poly
      cellcolors←(⊃⍴polyomino)⍴0
      filcol←fcol
      R theta phi←25 60 45
      vol dim←⍴polyomino                                         ⍝ Initialize perspective
      adjust                                                     ⍝ Setup the polygons
    ∇
     
    ∇ copy(frompolyd dumy1 dumy2 dumy3 dumy4)                         ⍝ Copy from another polyominod
      :Access Public
      :Implements Constructor
      polyomino polycols filcol cellcolors←frompolyd.(polyomino polycols filcol cellcolors)
      theta phi R vol dim←frompolyd.(theta phi R vol dim)
      polyid←frompolyd.⎕NC'polyid'
      :If polyid≠0
          polyid←frompolyd.polyid
      :EndIf
      adjust
    ∇
      
      ⍝=============== other public procedures
     
    ∇ addnewwithcolor(poly fcol)                                    ⍝ makes a polyomino with given color
      :Access Public
      polyid+←1
      polyomino⍪←3 adrlift poly
      cellcolors,←(⊃⍴poly)⍴polyid×3
      filcol,←3↑fcol
      adjust                                                       ⍝ Setup the polygons
    ∇

    ∇ removelast;polysize                                     ⍝ Remove the last polyomino from list
      :Access Public
      polysize←-+/cellcolors=polyid×3
      polyomino↓⍨←polysize 0
      cellcolors↓⍨←polysize
      filcol↓⍨←¯3
      polyid-←1
      adjust                                                       ⍝ Setup the polygons
    ∇
    
    ∇ remove no;keep                 ⍝ Remove number no polyomino from list
      :Access Public                                     
      keep←cellcolors≠no×3            ⍝ polysize←-+/cellcolors=no×3
      polyomino←↑keep/↓polyomino      ⍝ ←↓⍨←polysize 0
      cellcolors←keep/cellcolors      ⍝ ↓⍨←polysize
      ⍝ filcol←(3/keep)/filcol          ⍝ ↓⍨←¯3
      ⍝ polyid-←1
      adjust                                                       ⍝ Setup the polygons
    ∇
           
    ∇ polysetup;bascol;⎕RL;ns                                                   ⍝ Initiate calculation of 3d elements
      :Access Public
     
      cellcolors←(≢polyomino)⍴0
      ⍝ ⎕RL←10⊥(#.polyFns.nabosignature polyomino),index,7 
      ⎕RL←0
      bascol←?85 85 85
      filcol←(3×bascol)(2×bascol)(bascol)             ⍝ random base shades
     
      R theta phi←25 60 45                            ⍝ Initialize perspective
      adjust
    ∇
    
    ∇ makepalette                                     ⍝ Initiate calculation of 3d elements
      :Access Public
     
      shades←{240 160 80×3⍴⊂⍵}            ⍝  shades←{255 170 85×3⍴⊂⍵}
     
      filcol,←shades 1 0 0                            ⍝ red shades       3
      filcol,←shades 1 1 0                            ⍝ yellow shades    6
      filcol,←shades 0 1 0                            ⍝ green shades     9
      filcol,←shades 0 0 1                            ⍝ blue shades      12
      filcol,←shades 1 0 1                            ⍝ pink             15
      filcol,←shades 0 1 1                            ⍝ cyan             18
      filcol,←shades 1 1 1                            ⍝ white shades     21
      filcol,←shades 0 0 0                            ⍝ black shades     24
      polyid+←8
    ∇
    
    nodup←{(1=+/[0]⍵∘.≡u)/u←∪⍵} 

    adrlift←{↑(-⍺)↑¨↓⍵}       

    ∇ adjust;visibles
      :Access Public  
     
      allfaces←(↓adr2origo polyomino)∘.(+[1])(↑¨#.polyDB.std3surfaces)         ⍝ Put faces on each polyomino subcube
      visibles←,allfaces∊nodup,allfaces
      facecolors←cellcolors+[0](⍴allfaces)⍴1 2 0           ⍝ 0 1 2  or empty if invisible
      facetrack←⍳⍴allfaces
      ⍝ ⎕←'adjust' (⍴¨visibles allfaces facecolors facetrack)                                                     ⍝ polyid=⌊facecolor÷3
      facelist colorlist tracklist←{visibles/,⍵}¨allfaces facecolors facetrack
     
      poly3d                                                                 ⍝ Calculate polygons
    ∇
        
    ∇ poly3d;faceorder;projfaces;rotfaces;rotation          ⍝ Calculate polygons in 3D and right order
      :Access Public 
      rotation←(⊂⌊3÷⍨360|theta phi)⊃#.polyDB.std3rotations             ⍝ Get rotation matrix
      rotfaces←facelist(+.×)¨⊂rotation                              ⍝ Rotate each face
      projfaces←↑¨{⍵[1 0]÷1+⍵[2]÷R}¨∘↓¨rotfaces                     ⍝ Project each face onto viewplane
      faceorder←⍒{⌈/⍵[;2]}¨rotfaces                                 ⍝ Order each polygon after deepest z
     
      polygons←projfaces[faceorder]                                 ⍝ Projected Polygons in order
      polycols←filcol[colorlist[faceorder]]                         ⍝ Polygons fillcolors in order
      polytrack←tracklist[faceorder]                                ⍝ Track back from polygon faces to polyomino
    ∇
    
      adr2origo←{⍝ moves a polyomino so center of box coincides origo
          ⍵-[1](1+(⌈⌿⍵)+⌊⌿⍵)÷2
      } 
      
   ⍝   pvd←{⍝ Pics polyomino from base library or sporadic library
⍝        ⍺←⍬
⍝        vol dim←⍵
⍝        (⍺≡⍬)∧vol<10:(⊂⍵)⊃#.pdb.polyvoldim                 ⍝ Whole vol dim
⍝        (⍺≡⍬)∧vol∊10 11:pvdxtallin vol dim                 ⍝ Whole vol dim 
⍝        (⍺≢⍬)∧vol<10:((⊂⍵)⊃#.pdb.polyvoldim)[,⍺]           ⍝ Multiple items of same vol dim
⍝        (⍺≢⍬)∧vol∊10 11:(pvdxtallin vol dim)[,⍺]           ⍝ Whole vol dim 
⍝        11<vol:{(⍵≢¨⊂⍬)/⍵}(#.pdb.sporadicPieces.pvd)⊂⍺,⍵   ⍝ Sporadic case
⍝       }
      
     ⍝ pvd←{⍝ Pics polyomino from base library or sporadic library
⍝          ⍺←⍬
⍝          ⍺≡⍬:(⊂⍵)⊃#.pdb.polyvoldim                          ⍝ Whole vol dim
⍝          11<⊃⍵:{(⍵≢¨⊂⍬)/⍵}(#.pdb.sporadicPieces.pvd)⊂⍺,⍵    ⍝ Sporadic case
⍝          ((⊂⍵)⊃#.pdb.polyvoldim)[,⍺]                        ⍝ Multiple items of same vol dim
⍝      }
         
    ∇ mirror;pm ⍝ Replace polyomino with a mirrorimage along last axis
      :Access public  
      pm←{⍵×[1]((¯1+1⊃⍴⍵)⍴1),¯1}
      polyomino←pm polyomino
      adjust
    ∇
    
    ∇ turn                                ⍝ turns the polymino a little
      :Access Public     
      phi←360|phi-3                       ⍝ Turn 3 deggrees in rotation mode
      poly3d                              ⍝ Generate polygons
    ∇
    
    ∇ turnup                              ⍝ turns the polymino a little
      :Access Public     
      theta←360|theta-3                   ⍝ Turn 3 deggrees in rotation mode
      poly3d                              ⍝ Generate polygons
    ∇
    
    ∇ turnback                          ⍝ turns the polymino a little
      :Access Public     
      phi←360|phi+3                       ⍝ Turn -3 deggrees in rotation mode
      poly3d                              ⍝ Generate polygons
    ∇
    
    ∇ turndown                             ⍝ turns the polymino a little
      :Access Public     
      theta←360|theta+3                   ⍝ Turn -3 deggrees in rotation mode
      poly3d                              ⍝ Generate polygons
    ∇

    ∇ shiftturn rotate                    ⍝ Shifts and turns the polymino a little on external conveyer
      :Access Public 
      :If rotate=0
          poly3d                          ⍝ Generate polygons
      :ElseIf rotate=1
          turn
      :Else
          phi←360|phi-3×rotate            ⍝ Turn 3 deggrees in rotation mode
          poly3d                          ⍝ Generate polygons
      :End
      shift+←0.1                          ⍝ Increment the position
      polygons←polygons{⍺+[1]0,⍵}¨shift   ⍝ Shift the polygons with accumulated amount
    ∇
    
  ⍝  ∇ draw canvas                         ⍝ canvas is a form or subform
⍝      :Access Public 
⍝     
⍝      :With canvas.lines←canvas.⎕NEW'Poly'(⊂('Points'(,⊂2 2⍴0 0 1 1))) ⍝('Visible' 0))    ⍝ Polygon object with dummy points
⍝          Coord FCol←'user'(⊂192 192 192)
⍝          FStyle FillCol LStyle←0 0 0
⍝      :EndWith
⍝      canvas.lines.(Points FillCol)←polygons polycols   ⍝ Move calculated polygons to GUI
⍝      canvas.lines.OnTop←1
⍝    ∇
    
  ⍝  ∇ drawx canvas                         ⍝ canvas is a form or subform
⍝      :Access Public 
⍝      :With canvas.lines←canvas.⎕NEW'Poly'(⊂'Points'(,⊂2 2⍴0 0 1 1))    ⍝ Polygon object with dummy points
⍝          Coord FCol←'user'(⊂192 192 192)
⍝          FStyle FillCol LStyle←0 0 0
⍝      :EndWith
⍝      canvas.lines.(Points FillCol)←polygons polycols   ⍝ Move calculated polygons to GUI
⍝      canvas.OnTop←1
⍝    ∇
    
    ∇ draw canvas                         ⍝ canvas is a form or subform
      :Access Public
     
      :With canvas.lines←canvas.⎕NEW'Poly'(⊂'Points'(,⊂2 2⍴0 0 1 1))    ⍝ Polygon object with dummy points
          Coord FCol←'user'(⊂192 192 192)
          FStyle FillCol LStyle←0 0 0
      :EndWith
      canvas.lines.Points←polygons                          ⍝ Move calculated polygons to GUI
      canvas.lines.FillCol←polycols
      #.aa←polygons polycols
    ∇   
    
    ∇ res←sizeinfo      ⍝ Returns the dimensions of the envelope box
       :Access Public

      res←(≢polyomino)(1+(⌈⌿-⌊⌿)polyomino)(#.polyFns.countfragments polyomino)    ⍝ as func adrbox
    ∇

    ∇ maxhit←colorix addcell yxpos;cell;st;selfhit;hits;cellno;faceno ⍝ Add a new cell to the polyomino
      :Access Public
      hits←(↓¨polygons)hit¨yxpos                                       ⍝ Polygons that contains the point
      maxhit←⌈/hits/⍳⍴polygons
      :If maxhit≥0
          cellno faceno←⊃polytrack[maxhit]
          cell←cellno⊃↓polyomino                                            ⍝ The cell that was hit
          direction←faceno⊃(¯1 0 0)(0 ¯1 0)(0 0 ¯1)(1 0 0)(0 1 0)(0 0 1)   ⍝ Direction of the face that was hit
          newcell←cell+direction
          polyomino,[0]←newcell                                             ⍝ Add new cell
          cellcolors,←colorix
          adjust
      :EndIf                                                         ⍝ Calculate polygons
    ∇
    
    ∇ selfhit←repeatadd
      :Access Public
      newcell+←direction
      selfhit←(⊂newcell)∊↓polyomino
      :If ~selfhit
          polyomino,[0]←newcell                                             ⍝ Add new cell
          cellcolors,←¯1↑cellcolors
          adjust
      :EndIf
    ∇
       
    ∇ colorix delcell yxpos;cellno;volume;hits;maxhit                        ⍝ Remove a cell from the polyomino
      :Access Public
      hits←(↓¨polygons)hit¨yxpos                                       ⍝ Polygons that contains the point
      maxhit←⌈/hits/⍳⍴polygons
      :If maxhit≥0
          cellno←⊃⊃polytrack[maxhit]
          :If cellcolors[cellno]=colorix                                       ⍝ The cell that was hit
              polyomino←(cellno≠⍳⊃⍴polyomino)⌿polyomino                         ⍝ Comb it out
              cellcolors←(cellno≠⍳⍴cellcolors)⌿cellcolors
              adjust
          :Else
              cellcolors[cellno]←colorix
              adjust
          :EndIf
      :EndIf
    ∇
    
    ∇ maxhit←markcell yxpos;cellno;volume;hits;maxhit                        ⍝ Remove a cell from the polyomino
      :Access Public
      hits←(↓¨polygons)hit¨yxpos                                       ⍝ Polygons that contains the point
      maxhit←⌈/hits/⍳⍴polygons
      :If maxhit≥0
          cellno←⊃⊃polytrack[maxhit]
          cellcolors[cellno]←6 ⍝ yellow
          adjust
      :EndIf
    ∇
    
   ⍝ ∇ newcell←markface yxpos;cellno;volume;hits;maxhit                        ⍝ Remove a cell from the polyomino
⍝      :Access Public
⍝      hits←(↓¨polygons)hit¨yxpos                                       ⍝ Polygons that contains the point
⍝      maxhit←⌈/hits/⍳⍴polygons
⍝      :If maxhit≥0
⍝     
⍝          cellno faceno←⊃polytrack[maxhit]
⍝          cell←cellno⊃↓polyomino                                            ⍝ The cell that was hit
⍝          direction←faceno⊃(¯1 0 0)(0 ¯1 0)(0 0 ¯1)(1 0 0)(0 1 0)(0 0 1)   ⍝ Direction of the face that was hit
⍝          newcell←cell+direction
⍝     
⍝          cellcolors[cellno]←6 ⍝ yellow
⍝          adjust
⍝      :Else
⍝          newcell←⍬
⍝      :EndIf
⍝    ∇
    
    ∇ newcell←markfacex yxpos;cellno;volume;hits;maxhit;xpolygons                   ⍝ Remove a cell from the polyomino
      :Access Public
     
      hits←(↓¨polygons)hit¨yxpos                                       ⍝ Polygons that contains the point
      maxhit←⌈/hits/⍳⍴polygons
      :If maxhit≥0
          cellno faceno←⊃polytrack[maxhit]
          cell←cellno⊃↓polyomino                                            ⍝ The cell that was hit
          direction←faceno⊃(¯1 0 0)(0 ¯1 0)(0 0 ¯1)(1 0 0)(0 1 0)(0 0 1)   ⍝ Direction of the face that was hit
          newcell←cell direction
          polysize←-+/cellcolors=polyid×3
          :If (polyid=0)∨(cellno<(¯1+≢polyomino)-polysize)                      ⍝(~newcell∊↓lastpolyomino)
              yellowcell←cellno
          :EndIf
      :Else
          newcell←⍬ ⍬
      :EndIf
    ∇
    
    
   ⍝ ∇ newcell←markfacey yxpos;cellno;volume;hits;maxhit;xpolygons;coolcells                   ⍝ Remove a cell from the polyomino
⍝      :Access Public
⍝     
⍝      polysize←-+/cellcolors=polyid×3
⍝      coolcells←((¯1+≢polyomino)-polysize)≥⊃¨polytrack
⍝      xpolygons←coolcells/polygons
⍝      hits←(↓¨xpolygons)hit¨yxpos                           ⍝ Polygons that contains the point
⍝      maxhit←⌈/hits/⍳⍴xpolygons
⍝      :If maxhit≥0
⍝          cellno faceno←⊃polytrack[maxhit]
⍝          cell←cellno⊃↓polyomino                                            ⍝ The cell that was hit
⍝          direction←faceno⊃(¯1 0 0)(0 ¯1 0)(0 0 ¯1)(1 0 0)(0 1 0)(0 0 1)   ⍝ Direction of the face that was hit
⍝          newcell←cell direction
⍝          polysize←-+/cellcolors=polyid×3
⍝          :If (polyid=0)∨(cellno<(¯1+≢polyomino)-polysize)                      ⍝(~newcell∊↓lastpolyomino)
⍝              yellowcell←cellno
⍝          :EndIf
⍝      :Else
⍝          newcell←⍬ ⍬
⍝      :EndIf
⍝    ∇
    
    ∇ paintyellow
      :Access Public
     
      yellowcells,←⊂(yellowcell)(cellcolors[yellowcell])        ⍝ remeber cell and color
      cellcolors[yellowcell]←6        ⍝ yellow
      adjust
    ∇

    
    ∇ repaint(from count paletteid)          ⍝ repaint the different sections of the polyomino in original color
      :Access Public
     
      cellcolors[from+⍳count]←3×paletteid+8×paletteid>0    ⍝ palette base plus 24 fixed colors
      adjust
    ∇
    
    ∇ repaintall;cll;cllcol;pair ⍝ repaint all yellow cells to original
      :Access Public
     
      :For pair :In yellowcells
          cll cllcol←pair
          cellcolors[cll]←cllcol
      :EndFor
      adjust
      yellowcells←⍬
    ∇
    
    ∇ newcell←unmarkface yxpos;cellno;volume;hits;maxhit                        ⍝ Remove a cell from the polyomino
      :Access Public
      hits←(↓¨polygons)hit¨yxpos                                       ⍝ Polygons that contains the point
      maxhit←⌈/hits/⍳⍴polygons
      :If maxhit≥0
     
          cellno faceno←⊃polytrack[maxhit]
          cell←cellno⊃↓polyomino                                            ⍝ The cell that was hit
          direction←faceno⊃(¯1 0 0)(0 ¯1 0)(0 0 ¯1)(1 0 0)(0 1 0)(0 0 1)   ⍝ Direction of the face that was hit
          newcell←cell+direction
     
          cellcolors[cellno]←0 ⍝ default
          adjust
      :Else
          newcell←⍬
      :EndIf
    ∇
   
      hit←{ ⍝ Test if polygon contains point,  ⍺ is vector of vertex points, ⍵ is the point to be testet
          signs←×(⍺,¨1⌽⍺)lq¨⊂⍵                                    ⍝ Sign of each test
          2>(⌈/signs)-⌊/signs
      }
       
      lq←{x0 y0 x1 y1←⍺                                       ⍝ Equation of an edge evaluated on a point
          ((y0-y1)(x1-x0)x0(-x1))+.×(⍵,y1,y0)
      }
 
:EndClass
