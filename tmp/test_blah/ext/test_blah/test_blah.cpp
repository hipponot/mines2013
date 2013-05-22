#include "rice/Class.hpp"
#include "rice/String.hpp"

using namespace Rice;
int test_hello(Object bmp /* self */)
{
  //String str("hello, world - from C++ extension");
  return (rand() % 2);
}
extern "C"
void Init_test_blah()
{
  Class rb_cTest = define_class("BlahExt").define_method("hello", &test_hello);
}