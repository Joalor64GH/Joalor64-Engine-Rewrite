#include <Python.h>
#include <pybind11/embed.h>
#include <pybind11/eval.h>
#include <iostream>

namespace py = pybind11;

void doFile(const char *str)
{
    py::scoped_interpreter guard{};
    py::object scope = py::module_::import("__main__").attr("__dict__");
    py::eval_file(str, scope);
}

void callNative(const char * strclbk)
{
    auto mod = py::module::import("package");
    auto funcraw = mod.attr(strclbk);

    funcraw();
}