/*
 * Copyright (c) 2013, 2015 Oracle and/or its affiliates. All rights reserved. This
 * code is released under a tri EPL/GPL/LGPL license. You can use it,
 * redistribute it and/or modify it under the terms of the:
 *
 * Eclipse Public License version 1.0
 * GNU General Public License version 2
 * GNU Lesser General Public License version 2.1
 */
package org.jruby.truffle.nodes.cast;

import com.oracle.truffle.api.dsl.NodeChild;
import com.oracle.truffle.api.dsl.Specialization;
import com.oracle.truffle.api.frame.VirtualFrame;
import com.oracle.truffle.api.source.SourceSection;

import org.jruby.truffle.nodes.RubyNode;
import org.jruby.truffle.runtime.NotProvided;
import org.jruby.truffle.runtime.RubyContext;
import org.jruby.truffle.runtime.core.RubyProc;

@NodeChild(value = "child", type = RubyNode.class)
public abstract class ProcOrNullNode extends RubyNode {

    public ProcOrNullNode(RubyContext context, SourceSection sourceSection) {
        super(context, sourceSection);
    }

    public abstract RubyProc executeProcOrNull(Object proc);

    @Specialization
    public RubyProc doNotProvided(NotProvided proc) {
        return null;
    }

    @Specialization(guards = "isNil(nil)")
    public RubyProc doNil(Object nil) {
        return null;
    }

    @Specialization
    public RubyProc doProc(RubyProc proc) {
        return proc;
    }

    @Override
    public final RubyProc executeRubyProc(VirtualFrame frame) {
        return (RubyProc) execute(frame);
    }

}
