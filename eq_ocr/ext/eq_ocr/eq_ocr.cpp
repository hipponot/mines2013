#include "rice/Class.hpp"
#include "rice/String.hpp"

using namespace Rice;

int recognize_char(Object bmp /* self */)
{
  //String str("hello, world - from C++ extension");
  return (rand() % 2);
}
extern "C"
void Init_eq_ocr()
{
  Class rb_cTest = define_class("OcrExt").define_method("recognize_char", &recognize_char);
}