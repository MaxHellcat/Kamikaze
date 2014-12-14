/*
 *  macro.h
 *  K
 *
 *  Created by Arkadiev on 4.19.2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

// for-cycle short-cut
// doesn't allow to trace inside cycle in this IDE
#define fori(i, count, block) for (int i = 0; i < count; i++) block;

#define die(flag, msg, code) if (!flag) { printf(msg); throw code; }

#define implementMe() assert(!"implement me")
#define implement(what) assert(!what)
#define TODO(what) NSLog(@what)