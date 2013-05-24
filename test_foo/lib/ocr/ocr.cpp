#include "/home/vagrant/.rvm/gems/ruby-1.9.3-p429/gems/rice-1.5.1/rice/ruby_try_catch.hpp"
#include "/home/vagrant/.rvm/gems/ruby-1.9.3-p429/gems/rice-1.5.1/rice/Class.hpp"

//VALUE OCR = Qnil;

int recognize_char(int x)
{
	return rand() % 2;
}

extern "C"
void Init_ocr() {
	//RUBY_TRY
	//{
		Rice::Class ocr_ = Rice::define_class("OCR")
			.define_method("recognize_char", &recognize_char);
			//OCR = rb_define_module("OCR");
			//.rb_define_method(OCR, "recognize_char", recognize_char, 0);
	//}
  	//RUBY_CATCH
}

//void hello(std::string args) {
//   std::cout << args << std::endl;
//}
//extern "C"
// void Init_rubytest() {
//      Class test_ = define_class("Test")
//         .define_method("hello", &hello);
//}