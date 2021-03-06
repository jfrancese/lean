import ground_zero.types.heq
open ground_zero.types.dep_path (pathover_of_eq)

/-
  Sequential colimit.
  * https://homotopytypetheory.org/2016/01/08/colimits-in-hott/
-/

namespace ground_zero.HITs
universes u v

inductive colimit.core (α : ℕ → Sort u)
  (f : Π (n : ℕ), α n → α (n + 1))
| incl {} {n : ℕ} : α n → colimit.core

inductive colimit.rel (α : ℕ → Sort u)
  (f : Π (n : ℕ), α n → α (n + 1)) :
  colimit.core α f → colimit.core α f → Prop
| glue (n : ℕ) (x : α n) :
  colimit.rel (core.incl (f n x)) (core.incl x)

def colimit (α : ℕ → Sort u)
  (f : Π (n : ℕ), α n → α (n + 1)) :=
quot (colimit.rel α f)

namespace colimit
  variables {α : ℕ → Sort u} {f : Π (n : ℕ), α n → α (n + 1)}

  def incl {n : ℕ} (x : α n) : colimit α f :=
  quot.mk (rel α f) (core.incl x)

  abbreviation inclusion (n : ℕ) : α n → colimit α f := incl

  def glue {n : ℕ} (x : α n) : incl (f n x) = incl x :> colimit α f :=
  ground_zero.support.inclusion (quot.sound (colimit.rel.glue f n x))

  def ind {π : colimit α f → Sort v}
    (incl₁ : Π {n : ℕ} (x : α n), π (incl x))
    (glue₁ : Π {n : ℕ} (x : α n), incl₁ (f n x) =[glue x] incl₁ x) :
    Π x, π x := begin
    intro x, fapply quot.hrec_on x,
    { intro a, cases a with n r, exact incl₁ r },
    { intros, cases a with n a, cases b with m b,
      simp, cases p,
      fapply ground_zero.types.heq.from_pathover,
      apply glue, apply glue₁ }
  end

  def rec {π : Sort v} (incl₁ : Π {n : ℕ} (x : α n), π)
    (glue₁ : Π {n : ℕ} (x : α n), incl₁ (f n x) = incl₁ x :> π) :
    colimit α f → π :=
  ind @incl₁ (λ n x, pathover_of_eq (glue x) (glue₁ x))
end colimit

end ground_zero.HITs