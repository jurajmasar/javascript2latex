require 'spec_helper'
require 'javascript2latex'

describe Javascript2latex do
  it "should correctly format an invalid value" do
    Javascript2latex.make_tex("...").should == "$$"
  end  
  
  it "should correctly format a single variable" do
    Javascript2latex.make_tex("a").should == "$a$"
  end

  it "should not care about any whitespace in the expression" do
    Javascript2latex.make_tex("   a ").should == "$a$"
  end

  it "should should remove redundant brackets" do
    Javascript2latex.make_tex("((a))").should == "$a$"
    Javascript2latex.make_tex("((a+b))").should == "$a+b$"    
  end

  it "should correctly format addition of two variables" do
    Javascript2latex.make_tex("a+b").should == "$a+b$"
  end

  it "should correctly format subtraction of two variables" do
    Javascript2latex.make_tex("a-b").should == "$a-b$"
  end

  it "should correctly format multiplication of two variables" do
    Javascript2latex.make_tex("a*b").should == "$a \\times b$"
  end

  it "should correctly format division of two variables" do
    Javascript2latex.make_tex("a/b").should == "$\\frac{a}{b}$"
  end

  it "should correctly format square root" do
    Javascript2latex.make_tex("Math.sqrt(a)").should == "$\\sqrt{a}$"
    Javascript2latex.make_tex("Math.sqrt(a)+(a)").should == "$\\sqrt{a}+a$"  
  end

  it "should correctly format square logarithm" do
    Javascript2latex.make_tex("Math.log(a)").should == "$\\log{a}$"
    Javascript2latex.make_tex("Math.log(a)+(a)").should == "$\\log{a}+a$"    
    
  end

  it "should correctly format power" do
    Javascript2latex.make_tex("Math.pow(a,b)").should == "$a^{b}$"
    Javascript2latex.make_tex("Math.pow(a,b)+(a)").should == "$a^{b}+a$"        
    Javascript2latex.make_tex("Math.pow(a,b+c)").should == "$a^{b+c}$"    
    Javascript2latex.make_tex("Math.pow(a+b,c)").should == "$(a+b)^{c}$"    
  end

  it "should preserve the correct order of operations" do
    Javascript2latex.make_tex("(a+b)*c").should == "$(a+b) \\times c$"
  end

  it "should correctly format a composite expression" do
    Javascript2latex.make_tex("FV = PV*(Math.pow(1+r/100,n)-1)*(m/(r/100) + (1+m)/2)").should == "$FV=PV \\times ((1+\\frac{r}{100})^{n}-1) \\times (\\frac{m}{\\frac{r}{100}}+\\frac{1+m}{2})$"
  end
end