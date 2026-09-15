/* Assembler macros for the splat output.
 *
 * This file is OURS and is committed. It deliberately does not live in asm/,
 * which is generated, git-ignored, and deleted wholesale on a re-split.
 * scripts/build-elf.sh puts this directory on the assembler's include path.
 *
 * Hybrid Heaven: Recompiled took this file from Rayman 2: Recompiled. There
 * splat labelled data with `glabel` too, so data became FUNC symbols and had to
 * be filtered out of N64Recomp's input afterwards. Here tools/gen_splat_yaml.py
 * sets asm_data_macro: dlabel and asm_jtbl_label_macro: jlabel, so only real
 * functions get @function, and data and jump tables are @object.
 */

.macro glabel label
    .global \label
    .type \label, @function
    \label:
.endm

.macro dlabel label
    .global \label
    .type \label, @object
    \label:
.endm

.macro enddlabel label
    .size \label, . - \label
.endm

/* Global: the jump table is in a data object, the code using it in a text one. */
.macro jlabel label
    .global \label
    .type \label, @object
    \label:
.endm

/* spimdisasm emits `nonmatching <name>, <size>` immediately before each label,
 * and for a function that size is its true length in bytes. This is the ONLY
 * place a function's size appears in the output: `enddlabel` closes data
 * labels, but nothing closes a function. So this macro is where a func_ symbol
 * gets its st_size.
 *
 * That matters more than it looks. N64Recomp only recompiles a function whose
 * section words are non-empty, and it derives those from the symbol's size.
 * Stubbing this macro out leaves every function sized 0, and the recompiler
 * then silently emits nothing but the entrypoint -- no error, no warning.
 *
 * The size argument is optional because data labels are announced the same way
 * without one; those get their real size from `enddlabel` further down, which
 * overrides the zero set here.
 */
.macro nonmatching name, size=0
    .size \name, \size
.endm

.macro sizeof name, size
    .size \name, \size
.endm
