#include "ruby.h"
#include "tomboykeybinder.h"

static VALUE key_callback_hash;
static VALUE key_binder_class;

// the callback, that gets invoked when key is pressed
void handler_c_func(char *keystring, gpointer user_data)
{
  VALUE rb_keystring = rb_str_new2(keystring);

  VALUE callback_func = rb_hash_aref(key_callback_hash,rb_keystring);

  //rb_funcall(key_binder_class,rb_intern(StringValuePtr(callback_func)),0);
  rb_funcall(callback_func,rb_intern("call"),0);
}

// an instance method, which gets invoked when you bind the key
static VALUE rb_tomboy_binder(VALUE self,VALUE key_string, VALUE callback_string)
{
  /* VALUE key_callback_hash; */
  /* key_callback_hash = rb_iv_get(self,"@callback_hash_shit"); */
  /* if(NIL_P(key_callback_hash)) */
  /*   rb_raise(rb_eTypeError, "not valid value"); */

  rb_hash_aset(key_callback_hash,key_string,callback_string);

  char *input_key_string = StringValuePtr(key_string);

  tomboy_keybinder_bind(input_key_string,&handler_c_func,NULL);
  return Qnil;
}


static VALUE rb_initialize_keybinder(VALUE self)
{
  key_callback_hash = rb_hash_new();
  rb_iv_set(self,"@callback_hash_shit",key_callback_hash);
  rb_iv_set(self,"@valid",Qtrue);
  tomboy_keybinder_init();
  return self;
}


void Init_keybinder() {
  key_binder_class = rb_define_class("KeyBinder",rb_cObject);
  rb_define_method(key_binder_class,"initialize",rb_initialize_keybinder,0);
  rb_define_method(key_binder_class,"bindkey",rb_tomboy_binder,2);
}
