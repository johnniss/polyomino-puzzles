 pvdxttotout←{⍝ Put polyominoes to xt files

     vol dim←⍵                                ⍝ ⍵ is vol dim, ⍺ is boxdim

     root←(⊃#.pdb.roots[0]),'Pvd\Poly'                     ⍝ something like'Y:\Documents\jnhshared\xt\'
     filename←,('G⊂v99d99⊃'⎕FMT 100 1+.×vol dim)

     antal←⍴pvd vol dim
     ⍝ ⎕←(root,filename,'.DXV')antal
     antal>0:(root,filename,'.DXV')setxtvalue pvd vol dim
     0
     ⍝ putsinglebox¨⊆adrbox eqc pvd vol dim
 }
