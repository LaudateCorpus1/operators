# The Art of C++ / Operators

[![Release](https://img.shields.io/github/release/taocpp/operators.svg)](https://github.com/taocpp/operators/releases/latest)
[![Download](https://api.bintray.com/packages/taocpp/public-conan/operators%3Ataocpp/images/download.svg)](https://bintray.com/taocpp/public-conan/operators%3Ataocpp/_latestVersion)
[![TravisCI](https://travis-ci.org/taocpp/operators.svg?branch=master)](https://travis-ci.org/taocpp/operators)
[![AppVeyor](https://ci.appveyor.com/api/projects/status/794d875ucgic4sq0/branch/master?svg=true)](https://ci.appveyor.com/project/taocpp/operators)
[![Coverage](https://coveralls.io/repos/github/taocpp/operators/badge.svg?branch=master)](https://coveralls.io/github/taocpp/operators)
[![Language grade: C/C++](https://img.shields.io/lgtm/grade/cpp/g/taocpp/operators.svg)](https://lgtm.com/projects/g/taocpp/operators/context:cpp)

[The Art of C++](https://taocpp.github.io/) / Operators is a zero-dependency C++11 single-header library that provides highly efficient, move aware operators for arithmetic data types.

### Table of Content

[Overview](#overview)<br/>
[Example](#example)<br/>
[Requirements](#requirements)<br/>
[Installation](#installation)<br/>
[Provided Templates](#provided-templates)<br/>
[Commutativity](#commutativity)<br/>
[RValue References](#rvalue-references)<br/>
[constexpr](#constexpr)<br/>
[noexcept](#noexcept)<br/>
[nodiscard](#nodiscard)<br/>
[Changelog](#changelog)<br/>
[History](#history)<br/>
[License](#license)

## Overview

Overloaded operators for class types typically don't come alone.
For example, when `x + y` is possible then `x += y` should be, too.
When `x < y` is possible then `x > y`, `x >= y`, and `x <= y` should be, too.

Implementing large sets of operators, possibly for multiple classes, is both tedious and error-prone.
However, more often than not, some of these operators can be defined in terms of others.
For example `x >= y` can frequently be defined as `!(x < y)`.

Given the implementation of some basic operators, the templates in the Art of C++ / Operators can generate many more operators automatically.

The generated operators are overloaded to take advantage of movable types, and allow the compiler to avoid unneccessary temporary objects wherever possible.
All generated operators are `noexcept` when the underlying operations are `noexcept`.
Generated comparison operators are `constexpr` (when supported by the compiler).

## Example

Given this dummy integer class...

```c++
#include <tao/operators.hpp>

class MyInt
  : tao::operators::commutative_addable< MyInt >,
    tao::operators::multipliable< MyInt, double >
{
public:
  // create a new instance of MyInt
  MyInt( const int v ) noexcept;

  // copy and move constructor
  MyInt( const MyInt& v ) noexcept;
  MyInt( MyInt&& v ) noexcept; // optional

  // copy and move assignment
  MyInt& operator=( const MyInt& v ) noexcept;
  MyInt& operator=( MyInt&& v ) noexcept; // optional

  // addition of another MyInt
  MyInt& operator+=( const MyInt& v ) noexcept;
  MyInt& operator+=( MyInt&& v ) noexcept; // optional

  // multiplication by a scalar
  MyInt& operator*=( const double v ) noexcept;
};
```

...the base class templates will *generate* the following operators.

```c++
// generated by tao::operators::commutative_addable< MyInt >
MyInt   operator+( const MyInt& lhs, const MyInt& rhs ) noexcept;
MyInt&& operator+( const MyInt& lhs, MyInt&&      rhs ) noexcept;
MyInt&& operator+( MyInt&&      lhs, const MyInt& rhs ) noexcept;
MyInt&& operator+( MyInt&&      lhs, MyInt&&      rhs ) noexcept;

// generated by tao::operators::multipliable< MyInt, double >
MyInt   operator*( const MyInt& lhs, const double& rhs ) noexcept;
MyInt   operator*( const MyInt& lhs, double&&      rhs ) noexcept;
MyInt&& operator*( MyInt&&      lhs, const double& rhs ) noexcept;
MyInt&& operator*( MyInt&&      lhs, double&&      rhs ) noexcept;
```

>Note: The `// optional` in `class MyInt` above marks methods
>that you typically only add when your class benefits from an
>rvalue reference parameter. If there is no benefit for the
>implementation, you can just omit these methods. If you leave
>them out, The Art of C++ / Operators will simply call the corresponding
>non-movable version that takes the parameter by const lvalue
>reference.

## Requirements

Requires C++11 or newer. Tested with:

* GCC 4.7+
* Clang 3.2+
* Visual Studio 2015+

Remember to enable C++11, e.g., provide `-std=c++11` or similar options.

>Note: If you use or test the library with other compilers/versions,
>e.g., Visual C++, Intel C++, or any other compiler we'd like to hear from you.

>Note: For compilers that don't support `noexcept`, see chapter [noexcept](#noexcept).

## Installation

The Art of C++ / Operators is a single-header library. There is nothing to build or install,
just copy the header somewhere and include it in your code.

[Conan packages](https://bintray.com/taocpp/public-conan/operators%3Ataocpp) are available.

## Provided Templates

The following table gives an overview of the available templates.
Note that the "Provides" and "Requires" columns are just a basic overview.
Multiple overloads per provided operator might exist to ensure the most
efficient implementation for each case, exploiting move-semantics when
possible and (unless explicitly disabled) pass-through of temporary
values to avoid creating new temporaries.

Each overload of an operator is marked `noexcept` when the required operation(s)
that are used to implement it are also marked `noexcept`.

<table>

  <tr>
    <th>Template</th><th>Provides</th><th>Requires</th>
  </tr>

  <!-- equality_comparable -->
  <tr valign="top">
    <td>
      <code>equality_comparable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;!=&nbsp;T</code>
    </td><td>
      <code>T&nbsp;==&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>equality_comparable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;!=&nbsp;U</code><br/>
      <code>U&nbsp;==&nbsp;T</code><br/>
      <code>U&nbsp;!=&nbsp;T</code>
    </td><td>
      <code>T&nbsp;==&nbsp;U</code>
    </td>
  </tr>

  <!-- less_than_comparable -->
  <tr valign="top">
    <td>
      <code>less_than_comparable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&gt;&nbsp;T</code><br/>
      <code>T&nbsp;&lt;=&nbsp;T</code><br/>
      <code>T&nbsp;&gt;=&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&lt;&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>less_than_comparable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&lt;=&nbsp;U</code><br/>
      <code>T&nbsp;&gt;=&nbsp;U</code><br/>
      <code>U&nbsp;&lt;&nbsp;T</code><br/>
      <code>U&nbsp;&gt;&nbsp;T</code><br/>
      <code>U&nbsp;&lt;=&nbsp;T</code><br/>
      <code>U&nbsp;&gt;=&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&lt;&nbsp;U</code><br/>
      <code>T&nbsp;&gt;&nbsp;U</code>
    </td>
  </tr>

  <!-- equivalent -->
  <tr valign="top">
    <td>
      <code>equivalent&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;==&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&lt;&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>equivalent&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;==&nbsp;U</code>
    </td><td>
      <code>T&nbsp;&lt;&nbsp;U</code><br/>
      <code>T&nbsp;&gt;&nbsp;U</code>
    </td>
  </tr>

  <!-- partially_ordered -->
  <tr valign="top">
    <td>
      <code>partially_ordered&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&gt;&nbsp;T</code><br/>
      <code>T&nbsp;&lt;=&nbsp;T</code><br/>
      <code>T&nbsp;&gt;=&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&lt;&nbsp;T</code><br/>
      <code>T&nbsp;==&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>partially_ordered&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&lt;=&nbsp;U</code><br/>
      <code>T&nbsp;&gt;=&nbsp;U</code><br/>
      <code>U&nbsp;&lt;&nbsp;T</code><br/>
      <code>U&nbsp;&gt;&nbsp;T</code><br/>
      <code>U&nbsp;&lt;=&nbsp;T</code><br/>
      <code>U&nbsp;&gt;=&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&lt;&nbsp;U</code><br/>
      <code>T&nbsp;&gt;&nbsp;U</code><br/>
      <code>T&nbsp;==&nbsp;U</code>
    </td>
  </tr>

  <!-- addable -->
  <tr valign="top">
    <td>
      <code>commutative_addable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;+&nbsp;T</code>
    </td><td>
      <code>T&nbsp;+=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>commutative_addable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;+&nbsp;U</code><br/>
      <code>U&nbsp;+&nbsp;T</code>
    </td><td>
      <code>T&nbsp;+=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>addable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;+&nbsp;T</code>
    </td><td>
      <code>T&nbsp;+=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>addable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;+&nbsp;U</code>
    </td><td>
      <code>T&nbsp;+=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>addable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>U&nbsp;+&nbsp;T</code>
    </td><td>
      <code>T(&nbsp;U&nbsp;)</code><br/>
      <code>T&nbsp;+=&nbsp;T</code>
    </td>
  </tr>

  <!-- subtractable -->
  <tr valign="top">
    <td>
      <code>subtractable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;-&nbsp;T</code>
    </td><td>
      <code>T&nbsp;-=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>subtractable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;-&nbsp;U</code>
    </td><td>
      <code>T&nbsp;-=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>subtractable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>U&nbsp;-&nbsp;T</code>
    </td><td>
      <code>T(&nbsp;U&nbsp;)</code><br/>
      <code>T&nbsp;-=&nbsp;T</code>
    </td>
  </tr>

  <!-- multipliable -->
  <tr valign="top">
    <td>
      <code>commutative_multipliable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;*&nbsp;T</code>
    </td><td>
      <code>T&nbsp;*=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>commutative_multipliable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;*&nbsp;U</code><br/>
      <code>U&nbsp;*&nbsp;T</code>
    </td><td>
      <code>T&nbsp;*=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>multipliable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;*&nbsp;T</code>
    </td><td>
      <code>T&nbsp;*=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>multipliable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;*&nbsp;U</code>
    </td><td>
      <code>T&nbsp;*=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>multipliable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>U&nbsp;*&nbsp;T</code>
    </td><td>
      <code>T(&nbsp;U&nbsp;)</code><br/>
      <code>T&nbsp;*=&nbsp;T</code>
    </td>
  </tr>

  <!-- dividable -->
  <tr valign="top">
    <td>
      <code>dividable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;/&nbsp;T</code>
    </td><td>
      <code>T&nbsp;/=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>dividable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;/&nbsp;U</code>
    </td><td>
      <code>T&nbsp;/=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>dividable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>U&nbsp;/&nbsp;T</code>
    </td><td>
      <code>T(&nbsp;U&nbsp;)</code><br/>
      <code>T&nbsp;/=&nbsp;T</code>
    </td>
  </tr>

  <!-- modable -->
  <tr valign="top">
    <td>
      <code>modable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;%&nbsp;T</code>
    </td><td>
      <code>T&nbsp;%=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>modable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;%&nbsp;U</code>
    </td><td>
      <code>T&nbsp;%=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>modable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>U&nbsp;%&nbsp;T</code>
    </td><td>
      <code>T(&nbsp;U&nbsp;)</code><br/>
      <code>T&nbsp;%=&nbsp;T</code>
    </td>
  </tr>

  <!-- andable -->
  <tr valign="top">
    <td>
      <code>commutative_andable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&amp;&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&amp;=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>commutative_andable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&amp;&nbsp;U</code><br/>
      <code>U&nbsp;&amp;&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&amp;=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>andable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&amp;&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&amp;=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>andable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&amp;&nbsp;U</code>
    </td><td>
      <code>T&nbsp;&amp;=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>andable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>U&nbsp;&amp;&nbsp;T</code>
    </td><td>
      <code>T(&nbsp;U&nbsp;)</code><br/>
      <code>T&nbsp;&amp;=&nbsp;T</code>
    </td>
  </tr>

  <!-- orable -->
  <tr valign="top">
    <td>
      <code>commutative_orable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;|&nbsp;T</code>
    </td><td>
      <code>T&nbsp;|=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>commutative_orable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;|&nbsp;U</code><br/>
      <code>U&nbsp;|&nbsp;T</code>
    </td><td>
      <code>T&nbsp;|=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>orable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;|&nbsp;T</code>
    </td><td>
      <code>T&nbsp;|=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>orable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;|&nbsp;U</code>
    </td><td>
      <code>T&nbsp;|=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>orable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>U&nbsp;|&nbsp;T</code>
    </td><td>
      <code>T(&nbsp;U&nbsp;)</code><br/>
      <code>T&nbsp;|=&nbsp;T</code>
    </td>
  </tr>

  <!-- xorable -->
  <tr valign="top">
    <td>
      <code>commutative_xorable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;^&nbsp;T</code>
    </td><td>
      <code>T&nbsp;^=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>commutative_xorable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;^&nbsp;U</code><br/>
      <code>U&nbsp;^&nbsp;T</code>
    </td><td>
      <code>T&nbsp;^=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>xorable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;^&nbsp;T</code>
    </td><td>
      <code>T&nbsp;^=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>xorable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;^&nbsp;U</code>
    </td><td>
      <code>T&nbsp;^=&nbsp;U</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>xorable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>U&nbsp;^&nbsp;T</code>
    </td><td>
      <code>T(&nbsp;U&nbsp;)</code><br/>
      <code>T&nbsp;^=&nbsp;T</code>
    </td>
  </tr>

  <!-- left_shiftable -->
  <tr valign="top">
    <td>
      <code>left_shiftable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&lt;&lt;&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&lt;&lt;=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>left_shiftable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&lt;&lt;&nbsp;U</code>
    </td><td>
      <code>T&nbsp;&lt;&lt;=&nbsp;U</code>
    </td>
  </tr>

  <!-- right_shiftable -->
  <tr valign="top">
    <td>
      <code>right_shiftable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&gt;&gt;&nbsp;T</code>
    </td><td>
      <code>T&nbsp;&gt;&gt;=&nbsp;T</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>right_shiftable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>T&nbsp;&gt;&gt;&nbsp;U</code>
    </td><td>
      <code>T&nbsp;&gt;&gt;=&nbsp;U</code>
    </td>
  </tr>

  <!-- incrementable -->
  <tr valign="top">
    <td>
      <code>incrementable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T++</code>
    </td><td>
      <code>++T</code>
    </td>
  </tr>

  <!-- decrementable -->
  <tr valign="top">
    <td>
      <code>decrementable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>T--</code>
    </td><td>
      <code>--T</code>
    </td>
  </tr>

</table>

The following templates provide common groups of related operations.
For example, since a type which is left shiftable is usually also
right shiftable, the `shiftable` template provides the combined operators
of both.

<table>

  <tr>
    <th>Template</th><th>Provides</th>
  </tr>

  <!-- totally_ordered -->
  <tr valign="top">
    <td>
      <code>totally_ordered&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>equality_comparable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>less_than_comparable&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>totally_ordered&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>equality_comparable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>less_than_comparable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr>

  <!-- ring -->
  <tr valign="top">
    <td>
      <code>commutative_ring&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>commutative_addable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>subtractable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>commutative_multipliable&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>commutative_ring&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>commutative_addable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>subtractable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>subtractable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>commutative_multipliable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>ring&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>commutative_addable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>subtractable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>multipliable&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>ring&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>commutative_addable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>subtractable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>subtractable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>multipliable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr>

  <!-- field -->
  <tr valign="top">
    <td>
      <code>field&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>commutative_ring&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>dividable&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>field&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>commutative_ring&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>dividable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>dividable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr>

  <!-- ordered_commutative_ring -->
  <tr valign="top">
    <td>
      <code>ordered_commutative_ring&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>commutative_ring&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>totally_ordered&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>ordered_commutative_ring&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>commutative_ring&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>totally_ordered&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr>

  <!-- ordered_ring -->
  <tr valign="top">
    <td>
      <code>ordered_ring&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>ring&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>totally_ordered&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>ordered_ring&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>ring&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>totally_ordered&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr>

  <!-- ordered_field -->
  <tr valign="top">
    <td>
      <code>ordered_field&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>field&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>totally_ordered&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>ordered_field&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>field&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>totally_ordered&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr>

  <!-- bitwise -->
  <tr valign="top">
    <td>
      <code>commutative_bitwise&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>commutative_andable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>commutative_orable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>commutative_xorable&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>commutative_bitwise&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>commutative_andable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>commutative_orable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>commutative_xorable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>bitwise&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>andable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>orable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>xorable&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>bitwise&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>andable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>orable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>xorable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>bitwise_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>andable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>orable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>xorable_left&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr>

  <!-- shiftable -->
  <tr valign="top">
    <td>
      <code>shiftable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>left_shiftable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>right_shiftable&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr><tr valign="top">
    <td>
      <code>shiftable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td><td>
      <code>left_shiftable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code><br/>
      <code>right_shiftable&lt;&nbsp;T,&nbsp;U&nbsp;&gt;</code>
    </td>
  </tr>

  <!-- unit_steppable -->
  <tr valign="top">
    <td>
      <code>unit_steppable&lt;&nbsp;T&nbsp;&gt;</code>
    </td><td>
      <code>incrementable&lt;&nbsp;T&nbsp;&gt;</code><br/>
      <code>decrementable&lt;&nbsp;T&nbsp;&gt;</code>
    </td>
  </tr>

</table>

## Commutativity

For some templates, there are both [commutative](https://en.wikipedia.org/wiki/Commutative_property)
and non-commutative versions available. If the class you are writing is
commutative wrt an operation, you should prefer the commutative template,
i.e., the one which has `commutative_` at the beginning.

It will be *more efficient* in some cases because it can avoid an
extra temporary for the result and it has *fewer requirements*.

The one-argument version of the commutative template provides the same
operators as the non-commutative one, but you can see from the result type
in which cases creating a temporary (returning `T`) can be avoided
(returning `T&&`).

For the two-argument version, `commutative_{OP}< T, U >` provides the operators
of both `{OP}< T, U >` and `{OP}_left< T, U >`, again the return type indicates
those cases where an extra temporary is avoided.

## RValue References

As you can see above, several overloads of some operators return rvalue references.
This helps to eliminate temporaries in more complicated expressions, but some people
consider it dangerous. The argument against returning rvalue references usually
is something like:

```c++
const auto& result = a + b + c;
```

where they expect a temporary to be returned from the expression `a + b + c`,
and the lifetime of the temporary can be extended by binding it to a reference.

While this would work if an actual temporary value is returned, it does not work with
the second operator `+` returning an rvalue reference to the *intermediate* temporary
created by the first operator `+`.

I consider the above code bad style that has no place in modern C++. It should be
replaced by

```c++
const auto result = a + b + c;
```

and the problem goes away. Also, if you *expect* an expression to return a temporary
value, but you don't *verify* your assumption, it is your fault for basing your code
on those assumptions.

There is, however, one problem where the above binding to a references happens behind
the scenes, i.e. without being immediately visible. It may happen if you are using
a range-based for-loop. The problem in this case is not limited to returning rvalue
references, hence you should always make sure that you do not mix any kind of expression
other than directly naming a variable when using a range-based for-loop. Example:

```c++
// instead of this:
for( const auto& e : a + b + c ) { ... }

// always use something like this:
const auto r = a + b + c;
for( const auto& e : r ) { ... }
```

With all that said, you can disable returning rvalue references by defining
`TAO_OPERATORS_NO_RVALUE_REFERENCE_RESULTS`. If it is set, all operators will
return a value (an rvalue) instead of rvalue references.

## constexpr

All generated comparison operators are `constexpr` by default.
To switch off `constexpr` support simply

```c++
#define TAO_OPERATORS_CONSTEXPR
```

before including `<tao/operators.hpp>`.

Note that Visual C++ seems to have some problems with `constexpr` depending
on compile mode (debug/release), etc. and `constexpr` support is therefore
disabled by default. To manually enable it again use

```c++
#define TAO_OPERATORS_CONSTEXPR constexpr
```

before including `<tao/operators.hpp>`.

## noexcept

For compilers that do not support `noexcept`, the following might be a viable
work-around:

```c++
#include <utility> // make sure it's included before the following!
#define noexcept(...)
// you probably also need this for older compilers:
#define TAO_OPERATORS_CONSTEXPR
#include <tao/operators.hpp>
#undef noexcept
```

## nodiscard

When compiling with C++17 or higher, all generated methods are marked `[[nodiscard]]`.
For compilers that do not support `[[nodiscard]]` or when it is causing trouble,
you can disable it defining `TAO_OPERATORS_NODISCARD`:

```c++
#define TAO_OPERATORS_NODISCARD
#include <tao/operators.hpp>
```

## Changelog

### 1.2.2

Released 2019-06-04

* Fix `CMakeLists.txt` version number.

### 1.2.1

Released 2019-06-04

* Add work-around for MSVC to fix broken EBO in more cases.

### 1.2.0

Released 2019-03-30

* Add support for `[[nodiscard]]`.

### 1.1.1

Released 2018-06-17

* Automatic upload of Conan packages on release.

### 1.1.0

Released 2018-06-17

* Add `constexpr` support for comparison operators.

### 1.0.2

Released 2018-06-05

* Improve CMake support.
* Conan support.

### 1.0.1

Released 2018-04-23

* Work-around for MSVC to fix broken EBO.

### 1.0.0

Released 2018-02-13

* Initial release.

## History

The Art of C++ / Operators is a modernised C++11 rewrite of the [Boost.Operators](http://www.boost.org/doc/libs/1_66_0/libs/utility/operators.htm) library.

## License

The Art of C++ is certified [Open Source](http://www.opensource.org/docs/definition.html) software. It may be used for any purpose, including commercial purposes, at absolutely no cost. It is distributed under the terms of the [MIT license](http://www.opensource.org/licenses/mit-license.html) reproduced here.

> Copyright (c) 2013-2020 Daniel Frey
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
