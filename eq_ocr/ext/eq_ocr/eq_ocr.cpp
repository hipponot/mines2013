#include "rice/Class.hpp"
#include "rice/String.hpp"
using namespace Rice;
Object test_hello(Object /* self */)
{
  String str("hello, world - from C++ extension");
  return str;
}
extern "C"
void Init_eq_ocr()
{
  Class rb_cTest = define_class("OcrExt").define_method("hello", &test_hello);
}