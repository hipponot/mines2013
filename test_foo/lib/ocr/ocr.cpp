#include "rice/ruby_try_catch.hpp"
#include "ruby.h"

int recognize_char()
{
	return rand() % 2;
}

extern "C"
void Init_ocr() {
	RUBY_TRY
	{
	recognize_char = rb_define_module("OCR");
		.define_method("recognize_char", &recognize_char);
	}
  	RUBY_CATCH
}