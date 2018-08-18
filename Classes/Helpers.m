//
// Helpers.m
// kerchink
//
// Created by orta on 3/16/10.
// Copyright 2010 Apple Inc. All rights reserved.
//


#import "chipmunk.h"

extern cpSpace* space;
extern cpBody *staticBody;

cpBody* makeCircle(int radius){
	int num = 4;
	cpVect verts[] = {
		cpv(-radius, -radius),
		cpv(-radius, radius),
		cpv( radius, radius),
		cpv( radius, -radius),
	};
    // all physics stuff needs a body
	cpBody *body = cpBodyNew(1.0, cpMomentForPoly(1.0, num, verts, cpvzero));
	cpSpaceAddBody(space, body);
    // and a shape to represent its collision box
	cpShape* shape = cpCircleShapeNew(body, radius, cpvzero);
	shape->e = 0.1; shape->u = 0.5;
    //not strictly true, but its my game, I do what I want
	// shape->collision_type = kColl_Floor_balls;
	cpSpaceAddShape(space, shape);
	return body;
}

void makeStaticBox(float x, float y, float width, float height){
	cpShape * shape;
	shape = cpSegmentShapeNew(staticBody, cpv(x,y), cpv(x+width, y), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(x+width, y), cpv(x+width, y+height ), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(x+width, y+height), cpv(x, y+height ), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(x, y+height ), cpv(x, y), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
}

