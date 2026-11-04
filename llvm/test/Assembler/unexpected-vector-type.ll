; RUN: split-file %s %t
; RUN: not llvm-as %t/redundant.ll 2>&1 | FileCheck %s --check-prefix=REDUNDANT
; RUN: not llvm-as %t/global.ll 2>&1 | FileCheck %s --check-prefix=GLOBAL
; RUN: not llvm-as %t/scalable.ll 2>&1 | FileCheck %s --check-prefix=SCALABLE
; RUN: not llvm-as %t/missing-elt-type.ll 2>&1 | FileCheck %s --check-prefix=MISSING
; A real constant vector still parses.
; RUN: llvm-as %t/valid.ll -o /dev/null

; The vector type is already given by the instruction. Repeating it in front
; of the constant is not a constant vector; the elements are '<type value>'.
;--- redundant.ll
define void @redundant(<2 x i16> %in) {
  %arst = add <2 x i16> %in, <2 x i16> <i16 123, i16 456>
  ret void
}
; REDUNDANT: redundant.ll:2:31: error: unexpected vector type in constant; elements are written '<type value, ...>'

;--- global.ll
@g = global <2 x i16> <2 x i16> <i16 1, i16 2>
; GLOBAL: global.ll:1:24: error: unexpected vector type in constant; elements are written '<type value, ...>'

;--- scalable.ll
define void @scalable(<vscale x 2 x i16> %in) {
  %a = add <vscale x 2 x i16> %in, <vscale x 2 x i16> <i16 1, i16 2>
  ret void
}
; SCALABLE: scalable.ll:2:37: error: unexpected vector type in constant; elements are written '<type value, ...>'

; An element that simply omits its type is still "expected type".
;--- missing-elt-type.ll
define void @missing(<2 x i16> %in) {
  %b = add <2 x i16> %in, <123, 456>
  ret void
}
; MISSING: missing-elt-type.ll:2:28: error: expected type{{$}}

;--- valid.ll
define <2 x i16> @valid(<2 x i16> %in) {
  %arst = add <2 x i16> %in, <i16 123, i16 456>
  ret <2 x i16> %arst
}
