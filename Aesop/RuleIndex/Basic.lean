/-
Copyright (c) 2021 Jannis Limperg. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jannis Limperg
-/

import Aesop.Util

open Lean
open Lean.Meta
open Std (RBMap)

namespace Aesop

inductive IndexingMode : Type
  | unindexed
  | target (keys : Array DiscrTree.Key)
  | hyps (keys : Array DiscrTree.Key)
  deriving Inhabited

namespace IndexingMode

instance : ToFormat IndexingMode where
  format
    | unindexed => "unindexed"
    | target keys => f!"target {keys}"
    | hyps keys => f!"hyps {keys}"

def targetMatchingConclusion (type : Expr) : MetaM IndexingMode := do
  let path ← DiscrTree.getConclusionKeys type
  return target path

def hypsMatchingConst (decl : Name) : MetaM IndexingMode := do
  let path ← DiscrTree.getConstKeys decl
  return hyps path

end IndexingMode


inductive IndexMatchLocation
  | target
  | hyp (ldecl : LocalDecl)
  | none

namespace IndexMatchLocation

instance : ToMessageData IndexMatchLocation where
  toMessageData
    | target => "target"
    | hyp ldecl => m!"hyp {ldecl.userName}"
    | none => "none"

end IndexMatchLocation


structure IndexMatchResult (α : Type) where
  rule : α
  matchLocations : Array IndexMatchLocation
  deriving Inhabited

namespace IndexMatchResult

instance [Ord α] : Ord (IndexMatchResult α) where
  compare r s := compare r.rule s.rule

instance [Ord α] : LT (IndexMatchResult α) :=
  ltOfOrd

instance [ToMessageData α] : ToMessageData (IndexMatchResult α) where
  toMessageData r := toMessageData r.rule

end Aesop.IndexMatchResult
