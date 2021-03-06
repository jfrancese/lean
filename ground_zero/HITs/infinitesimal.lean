import ground_zero.types.equiv
open ground_zero.types.equiv (biinv)

/-
  The modality of shape infinitesimal in cohesive infinity topos.
  https://github.com/groupoid/cubical/blob/master/src/infinitesimal.ctt

  * HoTT 7.7 Modalities
-/

hott theory

namespace ground_zero.HITs.infinitesimal
universes u v

axiom im : Sort u → Sort u
constant im.unit {α : Sort u} : α → im α

def is_coreduced (α : Sort u) := biinv (@im.unit α)
axiom im.coreduced (α : Sort u) : is_coreduced (im α)

constant im.ind {α : Sort u} {β : im α → Sort v}
  (h : Π (i : im α), is_coreduced (β i))
  (f : Π (x : α), β (im.unit x)) :
  Π (x : im α), β x

constant im.ind.βrule {α : Sort u} {β : im α → Sort v}
  (h : Π (i : im α), is_coreduced (β i))
  (f : Π (x : α), β (im.unit x)) :
  Π (x : α), im.ind h f (im.unit x) = f x

noncomputable def im.rec {α : Sort u} {β : Sort v} (h : is_coreduced β)
  (f : α → β) : im α → β :=
im.ind (λ _, h) f

noncomputable def im.rec.βrule {α : Sort u} {β : Sort v}
  (h : is_coreduced β) (f : α → β) :
  Π (x : α), im.rec h f (im.unit x) = f x :=
im.ind.βrule (λ _, h) f

noncomputable def im.app {α : Sort u} {β : Sort v}
  (f : α → β) : im α → im β :=
im.rec (im.coreduced β) (im.unit ∘ f)

noncomputable def im.naturality {α : Sort u} {β : Sort v} (f : α → β) :
  Π (x : α), im.unit (f x) = im.app f (im.unit x) := begin
  intro x, unfold im.app, symmetry,
  transitivity, apply im.rec.βrule, trivial
end

end ground_zero.HITs.infinitesimal