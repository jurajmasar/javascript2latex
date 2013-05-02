== javascript2latex

Gem for creating LaTex expressions from JavaScript ones.

= Example

```ruby
Javascript2latex.make_tex("FV = PV*(Math.pow(1+r/100,n)-1)*(m/(r/100) + (1+m)/2)")
# => "$FV=PV \\times ((1+\\frac{r}{100})^{n}-1) \\times (\\frac{m}{\\frac{r}{100}}+\\frac{1+m}{2})$"
```

= Usage

See the tests in spec/javascript2latex_spec.rb

= Installation

You can add it to your Gemfile with:

```ruby
gem 'javascript2latex'
```

Or you can install it directly:

```ruby
gem install javascript2latex
```

= License

Copyright 2013 Juraj Masar. http://www.jurajmasar.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.