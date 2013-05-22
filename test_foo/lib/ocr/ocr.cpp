#include "ruby.h"

int recognize_char()
{
	return rand() % 2;
}

void Init_ocr() {
	Init_ocr = rb_define_module("OCR");
		.define_method("recognize_char", &recognize_char)
}