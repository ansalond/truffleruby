# Copyright (c) 2015, 2016 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require_relative '../../ruby/spec_helper'

describe "Truffle::Boot.ruby_home" do
  it "returns a String" do
    Truffle::Boot.ruby_home.should be_kind_of(String)
  end

  it "returns a path to a directory" do
    Dir.exist?(Truffle::Boot.ruby_home).should be_true
  end
end
