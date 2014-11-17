//  FSObjectBrowserViewObjectInfo.m Copyright (c) 2001-2009 Philippe Mougin.
//  This software is open source. See the license.

#import "FSObjectBrowserViewObjectInfo.h"
#import "FSObjectEnumInfo.h"
#import "FSObjectBrowserCell.h"
#import "FSObjectBrowserMatrix.h"
#import "FSNamedNumber.h"
#import "FSNumber.h"
#import "FSMiscTools.h"
#import "FSBoolean.h"
#import "FSBlock.h"
#import "BlockRep.h"
#import "FSGenericPointer.h"
#import "FSGenericPointerPrivate.h"
#import "FSObjectBrowserNamedObjectWrapper.h"
#import "FSObjectInspectorViewModelItem.h"
#import "FSNSString.h"
#import <objc/objc-class.h>
#import "FSGenericPointerPrivate.h"
#import "FSObjectPointerPrivate.h"
#import "FSCNClassDefinition.h"
#import "FSCNCategory.h"
#import "FSCNIdentifier.h"
#import "FSCNSuper.h"
#import "FSPattern.h"
#import "FSCNUnaryMessage.h"
#import "FSCNBinaryMessage.h"
#import "FSCNKeywordMessage.h"
#import "FSCNCascade.h"
#import "FSCNStatementList.h"
#import "FSCNPrecomputedObject.h"
#import "FSCNArray.h"
#import "FSCNBlock.h"
#import "FSCNAssignment.h"
#import "FSCNMethod.h"
#import "FSCNReturn.h"
#import "FSCNDictionary.h"
#import "FSAssociation.h"

@interface FSObjectBrowserViewObjectHelper : NSObject {
        FSObjectBrowserCell* selectedCell;
        NSString* selectedClassLabel;
        NSString* selectedLabel;
        id selectedObject;
        NSString* classLabel;
        NSMatrix* m;
        FSObjectBrowserView* view;
        NSMutableArray* baseClasses;
}

@property (nonatomic, retain) NSMutableArray* baseClasses;
@property (nonatomic, retain) FSObjectInspectorViewModelItem* rootViewModelItem;

- (id)initWithObjectBrowserView:(FSObjectBrowserView*)view;
- (void)fillMatrix:(NSMatrix*)m withObject:(id)object;

- (void)addFSGenericPointer:(id)object;
- (void)addFSObjectPointer:(id)object;
- (void)addNSAffineTransform:(id)object;
- (void)addNSAlert:(id)object;
- (void)addNSAnimation:(id)object;
- (void)addNSAnimationContext:(id)object;
- (void)addNSAttributedString:(id)object;
- (void)addNSBezierPath:(id)object;
- (void)addNSCell:(id)object;
- (void)addNSCollectionViewItem:(id)object;
- (void)addNSComparisonPredicate:(id)object;
- (void)addNSCompoundPredicate:(id)object;
- (void)addNSController:(id)object;
- (void)addNSCursor:(id)object;
- (void)addNSDockTile:(id)object;
- (void)addNSDocument:(id)object;
- (void)addNSDocumentController:(id)object;
- (void)addNSEntityDescription:(id)object;
- (void)addNSEvent:(id)object;
- (void)addNSExpression:(id)object;
- (void)addNSFetchRequest:(id)object;
- (void)addNSFileWrapper:(id)object;
- (void)addNSFont:(id)object;
- (void)addNSFontDescriptor:(id)object;
- (void)addNSFontManager:(id)object;
- (void)addNSGlyphInfo:(id)object;
- (void)addNSGlyphGenerator:(id)object;
- (void)addNSGradient:(id)object;
- (void)addNSGraphicsContext:(id)object;
- (void)addNSImage:(id)object;
- (void)addNSImageRep:(id)object;
- (void)addNSLayoutManager:(id)object;
- (void)addNSManagedObjectContext:(id)object;
- (void)addNSManagedObjectID:(id)object;
- (void)addNSManagedObjectModel:(id)object;
- (void)addNSMenu:(id)object;
- (void)addNSMenuItem:(id)object;
- (void)addNSOpenGLContext:(id)object;
- (void)addNSOpenGLPixelBuffer:(id)object;
- (void)addNSOpenGLPixelFormat:(id)object;
- (void)addNSPageLayout:(id)object;
- (void)addNSParagraphStyle:(id)object;
- (void)addNSPersistentStoreCoordinator:(id)object;
- (void)addNSPredicateEditorRowTemplate:(id)object;
- (void)addNSPropertyDescription:(id)object;
- (void)addNSResponder:(id)object;
- (void)addNSRulerMarker:(id)object;
- (void)addNSScreen:(id)object;
- (void)addNSShadow:(id)object;
- (void)addNSStatusBar:(id)object;
- (void)addNSStatusItem:(id)object;
- (void)addNSTabViewItem:(id)object;
- (void)addNSTableColumn:(id)object;
- (void)addNSTextAttachment:(id)object;
- (void)addNSTextBlock:(id)object;
- (void)addNSTextContainer:(id)object;
- (void)addNSTextList:(id)object;
- (void)addNSTextTab:(id)object;
- (void)addNSToolbar:(id)object;
- (void)addNSToolbarItem:(id)object;
- (void)addNSTrackingArea:(id)object;
- (void)addNSUndoManager:(id)object;
- (void)addNSATSTypesetter:(id)object;

- (void)processNSView:(id)object;
- (void)processNSControl:(id)object;
- (void)processNSWindow:(id)object;
@end


@implementation FSObjectBrowserView (FSObjectBrowserViewObjectInfo)


- (void)fillMatrix:(NSMatrix*)m column:(NSUInteger)col withObject:(id)object
{
        FSObjectBrowserViewObjectHelper* objectHelper = [[FSObjectBrowserViewObjectHelper alloc] initWithObjectBrowserView:self];
        [objectHelper fillMatrix:m withObject:object];

        [self addBlankRowToMatrix:m];
        [self fillMatrix:m withMethodsForObject:object];
        [self setRootViewModelObject:objectHelper.rootViewModelItem forColumn:col];

        [m sizeToCells];
        //[m scrollCellToVisibleAtRow:[matrix selectedRow] column:0];
        [m setNeedsDisplay];

        [objectHelper release];
}

@end


@implementation FSObjectBrowserViewObjectHelper

- (void)addObject:(id)object valueType:(FSInspectorVMValueType)valueType withLabel:(NSString*)label toMatrix:(NSMatrix*)matrix notNil:(BOOL)notNil
{
        @try {
                if (!notNil || object) {
                        [view addObject:object withLabel:label toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        FSObjectInspectorViewModelItem *item = [[FSObjectInspectorViewModelItem new] autorelease];
                        item.name = label;
                        item.valueType = valueType;
                        item.value = object;
                        [self.rootViewModelItem.mutableChildNodes addObject:item];
                }
        }
        @catch (id exception)
        {
                NSLog(@"%@", exception);
        }
}
#define ADD_ENUM(ENUM, OBJECT, LABEL) \
        [self addObject:objectFrom ## ENUM(OBJECT) valueType:FS_ITEM_ENUM withLabel:(LABEL) toMatrix:m notNil:NO];

#define ADD_OBJECT(OBJECT, LABEL)                                                                                                                                                           \
        @try {                                                                                                                                                                              \
                [view addObject:(OBJECT)withLabel:(LABEL)toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject]; \
        }                                                                                                                                                                                   \
        @catch (id exception) { NSLog(@"%@", exception); }

#define ADD_OBJECT_NOT_NIL(OBJECT, LABEL)                                                                                                                                                          \
        @try {                                                                                                                                                                                     \
                id object = (OBJECT);                                                                                                                                                              \
                if (object)                                                                                                                                                                        \
                        [view addObject:object withLabel:(LABEL)toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject]; \
        }                                                                                                                                                                                          \
        @catch (id exception) { NSLog(@"%@", exception); }

#define ADD_DICTIONARY(OBJECTS, LABEL)                                                                                                                                                                   \
        @try {                                                                                                                                                                                           \
                if ([(OBJECTS)count] <= 20)                                                                                                                                                              \
                        [view addDictionary:(OBJECTS)withLabel:(LABEL)toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject]; \
                else                                                                                                                                                                                     \
                        [self addObject:(OBJECTS) valueType:FS_ITEM_OBJECT withLabel:(LABEL)toMatrix:m notNil:NO];                                                                                                                 \
        }                                                                                                                                                                                                \
        @catch (id exception) { NSLog(@"%@", exception); }

#define ADD_OBJECTS(OBJECTS, LABEL)                                                                                                                                                                   \
        @try {                                                                                                                                                                                        \
                if ([(OBJECTS)count] <= 20)                                                                                                                                                           \
                        [view addObjects:(OBJECTS)withLabel:(LABEL)toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject]; \
                else                                                                                                                                                                                  \
                        [self addObject:(OBJECTS)valueType:FS_ITEM_OBJECT withLabel:(LABEL)toMatrix:m notNil:NO];                                                                                                              \
        }                                                                                                                                                                                             \
        @catch (id exception) { NSLog(@"%@", exception); }

#define ADD_BOOL(B, LABEL) \
        [self addObject:[FSBoolean booleanWithBool:(B)] valueType:FS_ITEM_BOOL withLabel:(LABEL)toMatrix:m notNil:NO];

#define ADD_NUMBER(NUMBER, LABEL) \
        [self addObject:[FSNumber numberWithDouble:(NUMBER)] valueType:FS_ITEM_NUMBER withLabel:(LABEL)toMatrix:m notNil:NO];

#define ADD_SEL(S, LABEL)                                                                                                                                                                                                                       \
        @try {                                                                                                                                                                                                                                  \
                [view addObject:[FSBlock blockWithSelector:(S)] withLabel:(LABEL)toMatrix:m leaf:YES classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject indentationLevel:0]; \
        }                                                                                                                                                                                                                                       \
        @catch (id exception) { NSLog(@"%@", exception); }

#define ADD_SEL_NOT_NULL(S, LABEL)                                                                                                                                                                                                                                   \
        @try {                                                                                                                                                                                                                                                       \
                {                                                                                                                                                                                                                                                    \
                        SEL selector = (S);                                                                                                                                                                                                                          \
                        if (selector != (SEL)0)                                                                                                                                                                                                                      \
                                [view addObject:[FSBlock blockWithSelector:selector] withLabel:(LABEL)toMatrix:m leaf:YES classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject indentationLevel:0]; \
                }                                                                                                                                                                                                                                                    \
        }                                                                                                                                                                                                                                                            \
        @catch (id exception) { NSLog(@"%@", exception); }

#define ADD_SIZE(SIZE, LABEL) \
        [self addObject:[NSValue valueWithSize:(SIZE)] valueType:FS_ITEM_SIZE withLabel:(LABEL)toMatrix:m notNil:NO];

#define ADD_RECT(RECT, LABEL) \
        [self addObject:[NSValue valueWithRect:(RECT)] valueType:FS_ITEM_RECT withLabel:(LABEL)toMatrix:m notNil:NO];

#define ADD_POINT(POINT, LABEL) \
        [self addObject:[NSValue valueWithPoint:(POINT)] valueType:FS_ITEM_POINT withLabel:(LABEL)toMatrix:m notNil:NO];

#define ADD_POINTER(POINTER, LABEL)                                                                                                                                                                                                                                                                                           \
        @try {                                                                                                                                                                                                                                                                                                                \
                if (POINTER == NULL)                                                                                                                                                                                                                                                                                          \
                        ADD_OBJECT(nil, LABEL) else [view addObject:[[[FSGenericPointer alloc] initWithCPointer:(POINTER)freeWhenDone:NO type:@encode(void)] autorelease] withLabel:(LABEL)toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject]; \
        }                                                                                                                                                                                                                                                                                                                     \
        @catch (id exception) { NSLog(@"%@", exception); }

#define ADD_RANGE(RANGE, LABEL) \
        [self addObject:[NSValue valueWithRange:(RANGE)] valueType:FS_ITEM_RANGE withLabel:(LABEL)toMatrix:m notNil:NO];

#define ADD_CLASS_LABEL(LABEL)                              \
        {                                                   \
                classLabel = (LABEL);                       \
                [view addClassLabel:classLabel toMatrix:m]; \
        }

@synthesize baseClasses;

- (id)init
{
        return [self initWithObjectBrowserView:nil];
}

- (id)initWithObjectBrowserView:(FSObjectBrowserView*)theView
{
        self = [super init];
        if (self) {

                if (!theView) {
                        return nil;
                }

                view = [[theView retain] autorelease];
                self.rootViewModelItem = [FSObjectInspectorViewModelItem new];
        }

        return self;
}

- (void)dealloc
{
        [baseClasses release];
        [_rootViewModelItem release];
        [super dealloc];
}

- (void)fillMatrix:(NSMatrix*)theMatrix withObject:(id)object
{

        [object retain]; // (1) To be sure object will not be deallocated as a side effect of the removing of rows

        m = theMatrix;
        selectedCell = [[[m selectedCell] retain] autorelease]; // retain and autorelease in order to avoid premature deallocation as a side effect of the removing of rows
        selectedClassLabel = [[[selectedCell classLabel] copy] autorelease]; // copy and autorelease in order to avoid premature invalidation as a side effect of the removing of rows
        selectedLabel = [[[selectedCell label] copy] autorelease]; // copy and autorelease in order to avoid premature invalidation as a side effect of the removing of rows
        selectedObject = [selectedCell representedObject];
        classLabel = @"";

        [m renewRows:0 columns:1];

        [view addObject:object toMatrix:m label:@"" classLabel:@"" indentationLevel:0 leaf:YES];
        [object release]; // It's now safe to match the retain in instruction (1)

        if (selectedObject == object && [selectedClassLabel isEqualToString:@""] && [selectedLabel isEqualToString:@""])
                [m selectCellAtRow:[m numberOfRows] - 1 column:0];

        if (object != nil && object == [object class]) // object is a class
        {
                NSMutableArray* classNames = [NSMutableArray array];
                NSUInteger count, i;
                Class* classes = allClasses(&count);

                @try {
                        for (i = 0; i < count; i++) {
#ifdef __LP64__
                                if (class_getSuperclass(classes[i]) == object)
                                        [classNames addObject:NSStringFromClass(classes[i])];
#else
                                if (classes[i]->super_class == object)
                                        [classNames addObject:NSStringFromClass(classes[i])];
#endif
                        }
                }
                @finally
                {
                        free(classes);
                }
                [classNames sortUsingFunction:FSCompareClassNamesForAlphabeticalOrder context:NULL];

                [view addBlankRowToMatrix:m];

#ifdef __LP64__
                if (class_getSuperclass(object) == nil)
                        [view addLabelAlone:@"This class is a root class" toMatrix:m];
                else
                        [view addObject:class_getSuperclass((Class)object) withLabel:@"Superclass" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
#else
                if (((Class)object)->super_class == nil)
                        [view addLabelAlone:@"This class is a root class" toMatrix:m];
                else
                        [view addObject:((Class)object)->super_class withLabel:@"Superclass" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
#endif

                if ([classNames count] == 0)
                        [view addLabelAlone:@"No subclasses" toMatrix:m];
                [view addClassesWithNames:classNames withLabel:@"Direct subclasses" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
        }
        else if ([object isKindOfClass:[NSManagedObject class]]) {
                NSManagedObject* o = object;
                classLabel = @"NSManagedObject Properties";
                NSArray* attributeKeys = [[[[o entity] attributesByName] allKeys] sortedArrayUsingSelector:@selector(compare:)];
                [view addPropertyLabel:@"Attributes" toMatrix:m];
                for (NSUInteger i = 0, count = [attributeKeys count]; i < count; i++) {
                        NSString* key = [attributeKeys objectAtIndex:i];
                        ADD_OBJECT([o valueForKey:key], key)
                }

                NSArray* relationshipKeys = [[[[o entity] relationshipsByName] allKeys] sortedArrayUsingSelector:@selector(compare:)];
                [view addPropertyLabel:@"Relationships" toMatrix:m];
                for (NSUInteger i = 0, count = [relationshipKeys count]; i < count; i++) {
                        NSString* key = [relationshipKeys objectAtIndex:i];
                        ADD_OBJECT([o valueForKey:key], key)
                }

                ADD_CLASS_LABEL(@"NSManagedObject Info");
                ADD_OBJECT([o entity], @"Entity")
                ADD_BOOL([o isDeleted], @"Is deleted")
                ADD_BOOL([o isInserted], @"Is inserted")
                ADD_BOOL([o isUpdated], @"Is updated")
                ADD_OBJECT([o managedObjectContext], @"Managed object context")
                ADD_OBJECT([o objectID], @"Object ID")
        }
        else if (([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSSet class]])
                 && [object count] < 500) // We display the elements only if there is less than a certain number of them
        {
                [view addBlankRowToMatrix:m];
                if ([object isKindOfClass:[NSArray class]]) {
                        NSArray* o = object;
                        if ([o count] == 0)
                                [view addLabelAlone:@"This array is empty" toMatrix:m];
                        [view addObjects:o withLabel:@"Elements" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* o = object;
                        if ([o count] == 0)
                                [view addLabelAlone:@"This dictionary is empty" toMatrix:m];
                        [view addDictionary:o withLabel:@"Entries" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[NSSet class]]) {
                        NSSet* o = object;
                        if ([o count] == 0)
                                [view addLabelAlone:@"This set is empty" toMatrix:m];
                        [view addObjects:[object allObjects] withLabel:@"Elements" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
        }
        else if ([object isKindOfClass:[FSAssociation class]]) {
                FSAssociation* o = object;
                [view addBlankRowToMatrix:m];
                [view addObject:[o key] withLabel:@"Key" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                [view addObject:[o value] withLabel:@"Value" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
        }
        else if ([object isKindOfClass:[NSView class]]) {
                NSView* o = object;
                [view addBlankRowToMatrix:m];

                [view addObject:[o superview] withLabel:@"Superview" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];

                if ([[o subviews] count] == 0)
                        [view addLabelAlone:@"No subviews" toMatrix:m];
                else
                        [view addObjects:[o subviews] withLabel:@"Subviews" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
        }
        else if ([object isKindOfClass:[FSCNBase class]]) {
                [view addBlankRowToMatrix:m];

                if ([object isKindOfClass:[FSCNArray class]]) {
                        FSCNArray* o = object;
                        if (o->count == 0)
                                [view addLabelAlone:@"An empty array" toMatrix:m];
                        else
                                [view addObjects:[NSArray arrayWithObjects:o->elements count:o->count] withLabel:@"Elements" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNAssignment class]]) {
                        FSCNAssignment* o = object;
                        [view addObject:o->left withLabel:@"lvalue" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        [view addObject:o->right withLabel:@"rvalue" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNBlock class]]) {
                        FSCNBlock* o = object;
                        [view addObject:[o->blockRep ast] withLabel:@"Abstract syntax tree" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNCascade class]]) {
                        FSCNCascade* o = object;
                        [view addObject:o->receiver withLabel:@"Receiver" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        [view addObjects:[NSArray arrayWithObjects:o->messages count:o->messageCount] withLabel:@"Message sends" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNCategory class]]) {
                        FSCNCategory* o = object;
                        [view addObject:o->className withLabel:@"Class name" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        [view addObjects:o->methods withLabel:@"Methods" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNClassDefinition class]]) {
                        FSCNClassDefinition* o = object;
                        [view addObject:o->className withLabel:@"Class name" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        [view addObject:o->superclassName withLabel:@"Superclass name" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        [view addObjects:o->civarNames withLabel:@"Class instance variables names" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        [view addObjects:o->ivarNames withLabel:@"Instance variables names" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        [view addObjects:o->methods withLabel:@"Methods" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNDictionary class]]) {
                        FSCNDictionary* o = object;
                        if (o->count == 0)
                                [view addLabelAlone:@"An empty dictionary" toMatrix:m];
                        else
                                [view addObjects:[NSArray arrayWithObjects:o->entries count:o->count] withLabel:@"Entries" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNMethod class]]) {
                        FSCNMethod* o = object;
                        [view addObject:o->method->code withLabel:@"Abstract syntax tree" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNMessage class]]) {
                        FSCNMessage* o = object;
                        [view addObject:o->receiver withLabel:@"Receiver" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];

                        if ([object isKindOfClass:[FSCNBinaryMessage class]]) {
                                FSCNBinaryMessage* o = object;
                                [view addObject:o->argument withLabel:@"Argument" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        }
                        else if ([object isKindOfClass:[FSCNKeywordMessage class]]) {
                                FSCNKeywordMessage* o = object;
                                [view addObjects:[NSArray arrayWithObjects:o->arguments count:o->argumentCount] withLabel:(o->argumentCount > 1 ? @"Arguments" : @"Argument")toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        }
                }
                else if ([object isKindOfClass:[FSCNPrecomputedObject class]]) {
                        FSCNPrecomputedObject* o = object;
                        [view addObject:o->object withLabel:@"Precomputed object" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNStatementList class]]) {
                        FSCNStatementList* o = object;
                        [view addObject:[NSNumber numberWithUnsignedInteger:o->statementCount] withLabel:@"Number of statements" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                        [view addObjects:[NSArray arrayWithObjects:o->statements count:o->statementCount] withLabel:@"Statements" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
                else if ([object isKindOfClass:[FSCNReturn class]]) {
                        FSCNReturn* o = object;
                        [view addObject:o->expression withLabel:@"Expression" toMatrix:m classLabel:@"" selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                }
        }

        /////////////////// Objective-C 2.0 declared properties ///////////////////
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FScriptAutomaticallyIntrospectDeclaredProperties"]) {
                Class cls = [object classOrMetaclass];
                while (cls) {
                        unsigned int i, count;
                        objc_property_t* properties = class_copyPropertyList(cls, &count);
                        if (properties != NULL && !(cls == [NSView class])) // Second part of condition is a quick fix to avoid bloating display for the NSView class with a "one property" section (10.5.0) or spurious properties (10.6). TODO: revise this.
                        {
                                classLabel = [NSString stringWithFormat:@"%@ Properties", [cls printString]];
                                [view addClassLabel:classLabel toMatrix:m color:[NSColor magentaColor]];

                                for (i = 0; i < count; i++) {
                                        NSString* propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
                                        NSString* propertyEncoding = [NSString stringWithUTF8String:property_getAttributes(properties[i])];
                                        NSError* error = nil;
                                        NSRegularExpression* customGetterRegexp = [NSRegularExpression regularExpressionWithPattern:@"(?:^G|,G)([^,]+)" options:0 error:&error];
                                        NSTextCheckingResult* customGetterMatch = [customGetterRegexp firstMatchInString:propertyEncoding options:0 range:NSMakeRange(0, propertyEncoding.length)];
                                        NSString* getter = propertyName;
                                        if (customGetterMatch) {
                                                getter = [propertyEncoding substringWithRange:[customGetterMatch rangeAtIndex:1]];
                                        }

                                        id propertyValue = nil; // initialized to nil in order to shut down a spurious warning
                                        NSString* errorMessage = nil;

                                        @try {
                                                propertyValue = [[[[@"[:object| object " stringByAppendingString:getter] stringByAppendingString:@"]"] asBlock] value:object];
                                        }
                                        @catch (id exception)
                                        {
                                                errorMessage = [@"F-Script can't display the value of this property. " stringByAppendingString:FSErrorMessageFromException(exception)];
                                                [view addObject:errorMessage withLabel:propertyName toMatrix:m leaf:YES classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject indentationLevel:0];
                                        }
                                        if (!errorMessage)
                                                ADD_OBJECT(propertyValue, propertyName)
                                }
                                free(properties);
                        }
                        if (cls == [cls superclass]) // Defensive programming against flawed class hierarchies with infinite loops.
                                cls = nil;
                        else
                                cls = [cls superclass];
                }
        }

        /////////////////// Bindings ///////////////////
        if ([object respondsToSelector:@selector(exposedBindings)] && [object respondsToSelector:@selector(infoForBinding:)]) {
                NSUInteger i, count;
                NSArray* exposedBindings = nil;

                // Several Cocoa objects have a buggy implementation of the exposedBindings method (e.g. NSTextView),
                // which leads to an exception being thrown when the method is called on certain *class* objects.
                // We work around these bugs here by preventing the buggy exception to interupt the current method.
                // Note: I'm writing this in Mac OS X 10.4.6.
                // Update for 10.5: the exposedBindings method now crash for certain class objects. I work around this
                // bellow by not calling it at all on class objects.
                @try {
                        if ([object class] != object)
                                exposedBindings = [object exposedBindings];
                }
                @catch (id exeption)
                {
                }

                if (exposedBindings) {
                        for (i = 0, count = [exposedBindings count]; i < count; i++)
                                if ([object infoForBinding:[exposedBindings objectAtIndex:i]])
                                        break;

                        if (i < count && count > 0) {
                                classLabel = @"Bindings";
                                [view addClassLabel:classLabel toMatrix:m color:[NSColor colorWithCalibratedRed:0 green:0.7098 blue:1 alpha:1]];

                                for (i = 0, count = [exposedBindings count]; i < count; i++) {
                                        [view addBindingForObject:object withName:[exposedBindings objectAtIndex:i] toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                                }

                                ADD_OBJECT(exposedBindings, @"Exposed Bindings");
                        }
                }
        }

        for (Class baseClass in self.baseClasses) {
                if ([object isKindOfClass:baseClass]) {
                        NSString* method = [NSString stringWithFormat:@"add%@:", [baseClass className]];
                        SEL selector = NSSelectorFromString(method);

                        NSAssert([self respondsToSelector:selector], @"Missing base class method");

                        [self performSelector:selector withObject:object];

                        break;
                }
        }
}

- (NSMutableArray*)baseClasses
{
        if (!baseClasses) {
                baseClasses = [[NSMutableArray alloc] initWithObjects:
                                                                          [FSGenericPointer class],
                                                                          [FSObjectPointer class],
                                                                          [NSAffineTransform class],
                                                                          [NSAlert class],
                                                                          [NSAnimation class],
                                                                          [NSAnimationContext class],
                                                                          [NSAttributedString class],
                                                                          [NSBezierPath class],
                                                                          [NSCell class],
                                                                          [NSCollectionViewItem class],
                                                                          [NSComparisonPredicate class],
                                                                          [NSCompoundPredicate class],
                                                                          [NSController class],
                                                                          [NSCursor class],
                                                                          [NSDockTile class],
                                                                          [NSDocument class],
                                                                          [NSDocumentController class],
                                                                          [NSEntityDescription class],
                                                                          [NSEvent class],
                                                                          [NSExpression class],
                                                                          [NSFetchRequest class],
                                                                          [NSFileWrapper class],
                                                                          [NSFont class],
                                                                          [NSFontDescriptor class],
                                                                          [NSFontManager class],
                                                                          [NSGlyphInfo class],
                                                                          [NSGlyphGenerator class],
                                                                          [NSGradient class],
                                                                          [NSGraphicsContext class],
                                                                          [NSImage class],
                                                                          [NSImageRep class],
                                                                          [NSLayoutManager class],
                                                                          [NSManagedObjectContext class],
                                                                          [NSManagedObjectID class],
                                                                          [NSManagedObjectModel class],
                                                                          [NSMenu class],
                                                                          [NSMenuItem class],
                                                                          [NSOpenGLContext class],
                                                                          [NSOpenGLPixelBuffer class],
                                                                          [NSOpenGLPixelFormat class],
                                                                          [NSPageLayout class],
                                                                          [NSParagraphStyle class],
                                                                          [NSPersistentStoreCoordinator class],
                                                                          [NSPredicateEditorRowTemplate class],
                                                                          [NSPropertyDescription class],
                                                                          [NSResponder class],
                                                                          [NSRulerMarker class],
                                                                          [NSScreen class],
                                                                          [NSShadow class],
                                                                          [NSStatusBar class],
                                                                          [NSStatusItem class],
                                                                          [NSTabViewItem class],
                                                                          [NSTableColumn class],
                                                                          [NSTextAttachment class],
                                                                          [NSTextBlock class],
                                                                          [NSTextContainer class],
                                                                          [NSTextList class],
                                                                          [NSTextTab class],
                                                                          [NSToolbar class],
                                                                          [NSToolbarItem class],
                                                                          [NSTrackingArea class],
                                                                          [NSUndoManager class],
                                                                          [NSATSTypesetter class],
                                                                          nil];
        }
        return baseClasses;
}
- (void)addFSGenericPointer:(id)object
{
        FSGenericPointer* o = object;
        NSArray* memoryContent = [o memoryContent];

        if (memoryContent) {
                ADD_CLASS_LABEL(@"FSGenericPointer Info");
                ADD_OBJECT(memoryContent, @"Memory content")
                ADD_OBJECT_NOT_NIL([o memoryContentUTF8], @"Memory content as UTF8 string")
        }
}

- (void)addFSObjectPointer:(id)object
{
        FSObjectPointer* o = object;
        NSArray* memoryContent = [o memoryContent];

        if (memoryContent) {
                ADD_CLASS_LABEL(@"FSObjectPointer Info");
                ADD_OBJECT(memoryContent, @"Memory content")
        }
}

- (void)addNSAffineTransform:(id)object
{
        NSAffineTransform* o = object;
        NSAffineTransformStruct s = [o transformStruct];
        ADD_CLASS_LABEL(@"NSAffineTransform Info");
        ADD_NUMBER(s.m11, @"m11")
        ADD_NUMBER(s.m12, @"m12")
        ADD_NUMBER(s.m21, @"m21")
        ADD_NUMBER(s.m22, @"m22")
        ADD_NUMBER(s.tX, @"tX")
        ADD_NUMBER(s.tY, @"tY")
}

- (void)addNSAlert:(id)object
{
        NSAlert* o = object;
        ADD_CLASS_LABEL(@"NSAlert Info");
        ADD_OBJECT([o accessoryView], @"Accessory view")
        ADD_ENUM(AlertStyle, [o alertStyle], @"Alert style")
        ADD_OBJECTS([o buttons], @"Buttons")
        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
        ADD_OBJECT_NOT_NIL([o helpAnchor], @"Help anchor")
        ADD_OBJECT([o icon], @"Icon")
        ADD_OBJECT([o informativeText], @"Informative text")
        ADD_OBJECT([o messageText], @"Message text")
        ADD_BOOL([o showsHelp], @"Shows help")
        ADD_BOOL([o showsSuppressionButton], @"Shows suppression button")
        ADD_OBJECT([o suppressionButton], @"Suppression button")
        ADD_OBJECT([o window], @"Window")
}

- (void)addNSAnimation:(id)object
{
        if ([object isKindOfClass:[NSViewAnimation class]]) {
                NSViewAnimation* o = object;

                if ([o viewAnimations] != nil) {
                        ADD_CLASS_LABEL(@"NSViewAnimation Info");
                        ADD_OBJECTS([o viewAnimations], @"View animations")
                }
        }

        NSAnimation* o = object;
        ADD_CLASS_LABEL(@"NSAnimation Info");
        ADD_ENUM(AnimationBlockingMode, [o animationBlockingMode], @"Animation blocking mode")
        ADD_ENUM(AnimationCurve, [o animationCurve], @"Animation curve")
        ADD_NUMBER([o currentProgress], @"Current progress")
        ADD_NUMBER([o currentValue], @"Current value")
        ADD_OBJECT([o delegate], @"Delegate")
        ADD_NUMBER([o duration], @"Duration (in seconds)")
        ADD_NUMBER([o frameRate], @"Frame rate")
        ADD_BOOL([o isAnimating], @"Is animating")
        ADD_OBJECTS([o progressMarks], @"Progress marks")
        ADD_OBJECT([o runLoopModesForAnimating], @"Run loop modes for animating")
}

- (void)addNSAnimationContext:(id)object
{
        NSAnimationContext* o = object;
        ADD_CLASS_LABEL(@"NSAnimationContext Info");
        ADD_NUMBER([o duration], @"Duration (in seconds)")
}

- (void)addNSAttributedString:(id)object
{
        if ([object isKindOfClass:[NSMutableAttributedString class]]) {
                if ([object isKindOfClass:[NSTextStorage class]]) {
                        NSTextStorage* o = object;
                        ADD_CLASS_LABEL(@"NSTextStorage Info");
                        //ADD_OBJECT(          [o attributeRuns]                      ,@"Attribute runs")
                        ADD_NUMBER([o changeInLength], @"Change in length")
                        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                        ADD_ENUM(TextStorageEditedOptions, [o editedMask], @"Edited mask")
                        ADD_RANGE([o editedRange], @"Edited range")
                        ADD_BOOL([o fixesAttributesLazily], @"Fixes attributes lazily")
                        ADD_OBJECT([o font], @"Font")
                        ADD_OBJECT([o foregroundColor], @"Foreground color")
                        ADD_OBJECTS([o layoutManagers], @"Layout managers")
                        // Note: invoking "paragraphs" and retaining the result cause the result of "layoutManager" to become trash !
                }
        }
}

- (void)addNSBezierPath:(id)object
{
        NSBezierPath* o = object;
        ADD_CLASS_LABEL(@"NSBezierPath Info");
        ADD_RECT([o bounds], @"Bounds")
        ADD_RECT([o controlPointBounds], @"Control point bounds")
        if (![o isEmpty])
                ADD_POINT([o currentPoint], @"Current point")
        ADD_NUMBER([o elementCount], @"Element count")
        ADD_NUMBER([o flatness], @"Flatness")
        ADD_BOOL([o isEmpty], @"Is empty")
        ADD_ENUM(LineCapStyle, [o lineCapStyle], @"Line cap style")
        ADD_ENUM(LineJoinStyle, [o lineJoinStyle], @"Line join style")
        ADD_NUMBER([o lineWidth], @"Line width")
        ADD_NUMBER([o miterLimit], @"Miter limit")
        ADD_ENUM(WindingRule, [o windingRule], @"Winding rule")
}

- (void)addNSCell:(id)object
{
        if ([object isKindOfClass:[NSActionCell class]]) {
                if ([object isKindOfClass:[NSButtonCell class]]) {
                        if ([object isKindOfClass:[NSMenuItemCell class]]) {
                                if ([object isKindOfClass:[NSPopUpButtonCell class]]) {
                                        NSPopUpButtonCell* o = object;
                                        ADD_CLASS_LABEL(@"NSPopUpButtonCell Info");
                                        ADD_BOOL([o altersStateOfSelectedItem], @"Alters state of selected item")
                                        ADD_ENUM(PopUpArrowPosition, [o arrowPosition], @"Arrow position")
                                        ADD_BOOL([o autoenablesItems], @"Autoenables Items")
                                        ADD_NUMBER([o indexOfSelectedItem], @"Index of selected item")
                                        ADD_OBJECTS([o itemArray], @"Item array")
                                        ADD_NUMBER([o numberOfItems], @"Number of items")
                                        ADD_OBJECT([o objectValue], @"Object value")
                                        ADD_ENUM(RectEdge, [o preferredEdge], @"Preferred edge")
                                        ADD_BOOL([o pullsDown], @"Pulls down")
                                        ADD_OBJECT([o selectedItem], @"Selected item")
                                        ADD_BOOL([o usesItemFromMenu], @"Uses item from menu")
                                }

                                NSMenuItemCell* o = object;
                                ADD_CLASS_LABEL(@"NSMenuItemCell Info");
                                if ([[o menuItem] image])
                                        ADD_NUMBER([o imageWidth], @"Image width")
                                ADD_BOOL([o isHighlighted], @"Is highlighted")
                                if (![[[o menuItem] keyEquivalent] isEqualToString:@""])
                                        ADD_NUMBER([o keyEquivalentWidth], @"Key equivalent width")
                                ADD_OBJECT([o menuItem], @"Menu item")
                                ADD_BOOL([o needsDisplay], @"Needs display")
                                ADD_BOOL([o needsSizing], @"Needs sizing")
                                ADD_NUMBER([o stateImageWidth], @"State image width")
                                ADD_NUMBER([o titleWidth], @"Title width")
                        }

                        NSButtonCell* o = object;
                        ADD_CLASS_LABEL(@"NSButtonCell Info");
                        ADD_OBJECT_NOT_NIL([o alternateImage], @"Alternate image")
                        ADD_OBJECT([o alternateTitle], @"Alternate title")
                        ADD_OBJECT([o attributedAlternateTitle], @"Attributed alternate title")
                        ADD_OBJECT([o attributedTitle], @"Attributed title")
                        ADD_OBJECT([o backgroundColor], @"Background color")
                        ADD_ENUM(BezelStyle, [o bezelStyle], @"Bezel style")
                        ADD_ENUM(GradientType, [o gradientType], @"Gradient type")
                        ADD_ENUM(CellStyleMask, [o highlightsBy], @"Highlights by")
                        ADD_BOOL([o imageDimsWhenDisabled], @"Image dims when disabled")
                        ADD_ENUM(CellImagePosition, [o imagePosition], @"Image position")
                        ADD_ENUM(ImageScaling, [o imageScaling], @"Image scaling")
                        ADD_BOOL([o isTransparent], @"Is transparent")
                        ADD_OBJECT_NOT_NIL([o keyEquivalentFont], @"Key equivalent font")
                        ADD_ENUM(KeyModifierMask, [o keyEquivalentModifierMask], @"Key equivalent modifier mask")
                        ADD_BOOL([o showsBorderOnlyWhileMouseInside], @"Shows border only while mouse inside")
                        ADD_ENUM(CellStyleMask, [o showsStateBy], @"Shows state by")
                        ADD_OBJECT_NOT_NIL([o sound], @"Sound")
                        ADD_OBJECT([o title], @"Title")
                }
                else if ([object isKindOfClass:[NSDatePickerCell class]]) {
                        NSDatePickerCell* o = object;
                        ADD_CLASS_LABEL(@"NSDatePickerCell Info");
                        ADD_OBJECT([o backgroundColor], @"Background color")
                        ADD_OBJECT([o calendar], @"Calendar")
                        ADD_ENUM(DatePickerElementFlags, [o datePickerElements], @"Date picker elements")
                        ADD_ENUM(DatePickerMode, [o datePickerMode], @"Date picker mode")
                        ADD_ENUM(DatePickerStyle, [o datePickerStyle], @"Date picker style")
                        ADD_OBJECT([o dateValue], @"Date value")
                        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                        ADD_BOOL([o drawsBackground], @"Draws background")
                        ADD_OBJECT_NOT_NIL([o locale], @"Locale")
                        ADD_OBJECT([o maxDate], @"Max date")
                        ADD_OBJECT([o minDate], @"Min date")
                        ADD_OBJECT([o textColor], @"Text Color")
                        ADD_NUMBER([o timeInterval], @"Time interval")
                        ADD_OBJECT([o timeZone], @"Time zone")
                }
                else if ([object isKindOfClass:[NSFormCell class]]) {
                        NSFormCell* o = object;
                        ADD_CLASS_LABEL(@"NSFormCell Info");
                        ADD_OBJECT([o attributedTitle], @"Attributed title")
                        ADD_OBJECT_NOT_NIL([o placeholderAttributedString], @"Placeholder attributed string")
                        ADD_OBJECT_NOT_NIL([o placeholderString], @"Placeholder string")
                        ADD_ENUM(TextAlignment, [o titleAlignment], @"Title alignment")
                        ADD_ENUM(WritingDirection, [o titleBaseWritingDirection], @"Title base writing direction")
                        ADD_OBJECT([o titleFont], @"Title font")
                        ADD_NUMBER([o titleWidth], @"Title width")
                }
                else if ([object isKindOfClass:[NSLevelIndicatorCell class]]) {
                        NSLevelIndicatorCell* o = object;
                        ADD_CLASS_LABEL(@"NSLevelIndicatorCell Info");
                        ADD_NUMBER([o criticalValue], @"Critical value")
                        ADD_ENUM(LevelIndicatorStyle, [o levelIndicatorStyle], @"Level indicator style")
                        ADD_NUMBER([o maxValue], @"Max value")
                        ADD_NUMBER([o minValue], @"Min value")
                        ADD_NUMBER([o numberOfMajorTickMarks], @"Number of major tick marks")
                        ADD_NUMBER([o numberOfTickMarks], @"Number of tick marks")
                        ADD_OBJECT(objectFromTickMarkPosition([o tickMarkPosition], NO), @"Tick mark position")
                        ADD_NUMBER([o warningValue], @"Warning value")
                }
                else if ([object isKindOfClass:[NSPathCell class]]) {
                        NSPathCell* o = object;
                        ADD_CLASS_LABEL(@"NSPathCell Info");
                        ADD_OBJECTS([o allowedTypes], @"Allowed types")
                        ADD_OBJECT_NOT_NIL([o backgroundColor], @"Background color")
                        ADD_OBJECT([o delegate], @"Delegate")
                        ADD_SEL([o doubleAction], @"Double action")
                        ADD_OBJECTS([o pathComponentCells], @"Path component cells")
                        ADD_ENUM(PathStyle, [o pathStyle], @"Path style")
                        ADD_OBJECT_NOT_NIL([o placeholderAttributedString], @"Placeholder attributed string")
                        ADD_OBJECT_NOT_NIL([o placeholderString], @"Placeholder string")
                        ADD_OBJECT_NOT_NIL([o URL], @"URL")
                }
                else if ([object isKindOfClass:[NSSegmentedCell class]]) {
                        NSSegmentedCell* o = object;
                        NSInteger segmentCount = [o segmentCount];
                        ADD_CLASS_LABEL(@"NSSegmentedCell Info");

                        ADD_NUMBER(segmentCount, @"Segment count")
                        ADD_NUMBER([o selectedSegment], @"Selected segment")
                        ADD_ENUM(SegmentSwitchTracking, [o trackingMode], @"Tracking mode")

                        for (NSInteger i = 0; i < segmentCount; i++) {
                                ADD_OBJECT_NOT_NIL([o imageForSegment:i], ([NSString stringWithFormat:@"Image for segment %ld", (long)i]))
                                ADD_OBJECT(objectFromImageScaling([o imageScalingForSegment:i]), ([NSString stringWithFormat:@"Image scaling for segment %ld", (long)i]))
                                ADD_BOOL([o isEnabledForSegment:i], ([NSString stringWithFormat:@"Is enabled for segment %ld", (long)i]))
                                ADD_BOOL([o isSelectedForSegment:i], ([NSString stringWithFormat:@"Is selected for segment %ld", (long)i]))
                                ADD_OBJECT_NOT_NIL([o labelForSegment:i], ([NSString stringWithFormat:@"Label for segment %ld", (long)i]))
                                ADD_OBJECT_NOT_NIL([o menuForSegment:i], ([NSString stringWithFormat:@"Menu for segment %ld", (long)i]))
                                ADD_NUMBER([o tagForSegment:i], ([NSString stringWithFormat:@"Tag for segment %ld", (long)i]))
                                ADD_OBJECT_NOT_NIL([o toolTipForSegment:i], ([NSString stringWithFormat:@"Tool tip for segment %ld", (long)i]))
                                ADD_NUMBER([o widthForSegment:i], ([NSString stringWithFormat:@"Width for segment %ld", (long)i]))
                        }
                }
                else if ([object isKindOfClass:[NSSliderCell class]]) {
                        NSSliderCell* o = object;
                        ADD_CLASS_LABEL(@"NSSliderCell Info");
                        ADD_BOOL([o allowsTickMarkValuesOnly], @"Allows tick mark values only")
                        ADD_NUMBER([o altIncrementValue], @"Alt increment value")
                        ADD_NUMBER([(NSSliderCell*)o isVertical], @"Is vertical")
                        ADD_NUMBER([o knobThickness], @"Knob thickness")
                        ADD_NUMBER([o maxValue], @"Max value")
                        ADD_NUMBER([o minValue], @"Min value")
                        ADD_NUMBER([o numberOfTickMarks], @"Number of tick marks")
                        ADD_ENUM(SliderType, [o sliderType], @"Slider type")
                        ADD_OBJECT(objectFromTickMarkPosition([o tickMarkPosition], [(NSSliderCell*)o isVertical] == 1), @"Tick mark position")
                        ADD_RECT([o trackRect], @"Track rect")
                }
                else if ([object isKindOfClass:[NSStepperCell class]]) {
                        NSStepperCell* o = object;
                        ADD_CLASS_LABEL(@"NSStepperCell Info");
                        ADD_BOOL([o autorepeat], @"Autorepeat")
                        ADD_NUMBER([o increment], @"Increment")
                        ADD_NUMBER([o maxValue], @"Max value")
                        ADD_NUMBER([o minValue], @"Min value")
                        ADD_BOOL([o valueWraps], @"Value wraps")
                }
                else if ([object isKindOfClass:[NSTextFieldCell class]]) {
                        if ([object isKindOfClass:[NSComboBoxCell class]]) {
                                NSComboBoxCell* o = object;
                                ADD_CLASS_LABEL(@"NSComboBoxCell Info");
                                if ([o usesDataSource])
                                        ADD_OBJECT([o dataSource], @"Data source")
                                ADD_BOOL([o hasVerticalScroller], @"Has vertical scroller")
                                ADD_NUMBER([o indexOfSelectedItem], @"Index of selected item")
                                ADD_SIZE([o intercellSpacing], @"Intercell spacing")
                                ADD_BOOL([o isButtonBordered], @"Is button bordered")
                                ADD_NUMBER([o itemHeight], @"Item height")
                                ADD_NUMBER([o numberOfItems], @"Number of items")
                                ADD_NUMBER([o numberOfVisibleItems], @"Number of visible items")
                                if (![o usesDataSource] && [o indexOfSelectedItem] != -1)
                                        ADD_OBJECT([o objectValueOfSelectedItem], @"Object value of selected item")
                                if (![o usesDataSource])
                                        ADD_OBJECTS([o objectValues], @"Object values")
                                ADD_BOOL([o usesDataSource], @"Uses data source")
                        }
                        else if ([object isKindOfClass:[NSPathComponentCell class]]) {
                                NSPathComponentCell* o = object;
                                ADD_CLASS_LABEL(@"NSPathComponentCell Info");
                                ADD_OBJECT_NOT_NIL([o image], @"Image")
                                ADD_OBJECT_NOT_NIL([o URL], @"URL")
                        }
                        else if ([object isKindOfClass:[NSSearchFieldCell class]]) {
                                NSSearchFieldCell* o = object;
                                ADD_CLASS_LABEL(@"NSSearchFieldCell Info");
                                ADD_OBJECT([o cancelButtonCell], @"Cancel button cell")
                                ADD_NUMBER([o maximumRecents], @"Maximum recents")
                                ADD_OBJECTS([o recentSearches], @"Recent searches")
                                ADD_OBJECT_NOT_NIL([o recentsAutosaveName], @"Recents autosave name")
                                ADD_OBJECT([o searchButtonCell], @"Search button cell")
                                ADD_OBJECT_NOT_NIL([o searchMenuTemplate], @"Search menu template")
                                ADD_BOOL([o sendsSearchStringImmediately], @"Sends search string immediately")
                                ADD_BOOL([o sendsWholeSearchString], @"Sends whole search string")
                        }
                        else if ([object isKindOfClass:[NSTokenFieldCell class]]) {
                                NSTokenField* o = object;
                                ADD_CLASS_LABEL(@"NSTokenField Info");
                                ADD_NUMBER([o completionDelay], @"Completion delay")
                                ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                                ADD_OBJECT([o tokenizingCharacterSet], @"Tokenizing character set")
                                ADD_ENUM(TokenStyle, [o tokenStyle], @"Token style")
                        }

                        NSTextFieldCell* o = object;
                        ADD_CLASS_LABEL(@"NSTextFieldCell Info");
                        ADD_OBJECTS([o allowedInputSourceLocales], @"Allowed input source locales")
                        ADD_OBJECT([o backgroundColor], @"Background color")
                        ADD_ENUM(TextFieldBezelStyle, [o bezelStyle], @"Bezel style")
                        ADD_BOOL([o drawsBackground], @"Draws background")
                        ADD_OBJECT_NOT_NIL([o placeholderAttributedString], @"Placeholder attributed string")
                        ADD_OBJECT_NOT_NIL([o placeholderString], @"Placeholder string")
                        ADD_OBJECT([o textColor], @"Text color")
                }
        }
        else if ([object isKindOfClass:[NSBrowserCell class]]) {
                NSBrowserCell* o = object;
                ADD_CLASS_LABEL(@"NSBrowserCell Info");
                ADD_OBJECT_NOT_NIL([o alternateImage], @"Alternate image")
                ADD_BOOL([o isLeaf], @"Is leaf")
                ADD_BOOL([o isLoaded], @"Is loaded")
        }
        else if ([object isKindOfClass:[NSImageCell class]]) {
                NSImageCell* o = object;
                ADD_CLASS_LABEL(@"NSImageCell Info");
                ADD_ENUM(ImageAlignment, [o imageAlignment], @"Image alignment")
                ADD_ENUM(ImageScaling, [o imageScaling], @"Image scaling")
        }
        else if ([object isKindOfClass:[NSTextAttachmentCell class]]) {
                NSTextAttachmentCell* o = object;
                ADD_CLASS_LABEL(@"NSTextAttachmentCell Info");
                ADD_OBJECT([o attachment], @"Attachment")
                ADD_POINT([o cellBaselineOffset], @"Cell baseline offset")
                ADD_SIZE([o cellSize], @"Cell size")
                ADD_BOOL([o wantsToTrackMouse], @"Wants to track mouse")
        }

        NSCell* o = object;
        ADD_CLASS_LABEL(@"NSCell Info");
        ADD_BOOL([o acceptsFirstResponder], @"Accepts first responder")
        ADD_SEL_NOT_NULL([o action], @"Action")
        ADD_ENUM(TextAlignment, [o alignment], @"Alignment")
        ADD_BOOL([o allowsEditingTextAttributes], @"Allows editing text attributes")
        ADD_BOOL([o allowsMixedState], @"Allows mixed state")
        ADD_BOOL([o allowsUndo], @"Allows undo")
        //ADD_OBJECT(              [o attributedStringValue]              ,@"Attributed string value")
        ADD_ENUM(BackgroundStyle, [o backgroundStyle], @"Background style")
        ADD_ENUM(WritingDirection, [o baseWritingDirection], @"Base writing direction")
        ADD_SIZE([o cellSize], @"Cell size")
        ADD_ENUM(ControlSize, [o controlSize], @"Control size")
        ADD_ENUM(ControlTint, [o controlTint], @"Control tint")
        ADD_OBJECT_NOT_NIL([o controlView], @"Control view")
        ADD_ENUM(FocusRingType, [o focusRingType], @"Focus ring type")
        ADD_OBJECT([o font], @"Font")
        ADD_OBJECT_NOT_NIL([o formatter], @"Formatter")
        ADD_OBJECT_NOT_NIL([o image], @"Image")
        if ([(NSCell*)o type] == NSTextCellType)
                ADD_BOOL([o importsGraphics], @"Imports graphics")
        ADD_ENUM(BackgroundStyle, [o interiorBackgroundStyle], @"Interior background style")
        ADD_BOOL([o isBezeled], @"Is bezeled")
        ADD_BOOL([o isBordered], @"Is bordered")
        ADD_BOOL([o isContinuous], @"Is continuous")
        ADD_BOOL([o isEditable], @"Is editable")
        ADD_BOOL([o isEnabled], @"Is enabled")
        ADD_BOOL([o isHighlighted], @"Is highlighted")
        ADD_BOOL([o isOpaque], @"Is opaque")
        ADD_BOOL([o isScrollable], @"Is scrollable")
        ADD_BOOL([o isSelectable], @"Is selectable")
        if ([[o keyEquivalent] length] != 0)
                ADD_OBJECT([o keyEquivalent], @"Key equivalent")
        ADD_ENUM(LineBreakMode, [o lineBreakMode], @"Line break mode")
        ADD_OBJECT_NOT_NIL([o menu], @"Menu")
        if ([[o mnemonic] length] != 0)
                ADD_OBJECT([o mnemonic], @"Mnemonic")
        if ([o mnemonicLocation] != NSNotFound)
                ADD_NUMBER([o mnemonicLocation], @"Mnemonic location")
        ADD_ENUM(CellStateValue, [o nextState], @"Next state")
        //ADD_OBJECT(              [o objectValue]                        ,@"Object value")
        ADD_BOOL([o refusesFirstResponder], @"Refuses first responder")
        ADD_OBJECT_NOT_NIL([o representedObject], @"Represented object")
        ADD_BOOL([o sendsActionOnEndEditing], @"Sends action on end editing")
        ADD_BOOL([o showsFirstResponder], @"Shows first responder")
        ADD_ENUM(CellStateValue, [o state], @"State")
        ADD_NUMBER([o tag], @"Tag")
        ADD_OBJECT_NOT_NIL([o target], @"Target")
        ADD_ENUM(CellType, [(NSCell*)o type], @"Type")
        ADD_BOOL([o wantsNotificationForMarkedText], @"Wants notification for marked text")
        ADD_BOOL([o wraps], @"Wraps")
}

- (void)addNSCollectionViewItem:(id)object
{
        NSCollectionViewItem* o = object;
        ADD_CLASS_LABEL(@"NSCollectionViewItem Info");
        ADD_OBJECT([o collectionView], @"Collection view")
        ADD_BOOL([o isSelected], @"Is selected")
        ADD_OBJECT([o representedObject], @"Represented object")
        ADD_OBJECT_NOT_NIL([o view], @"View")
}

- (void)addNSComparisonPredicate:(id)object
{
        NSComparisonPredicate* o = object;
        ADD_CLASS_LABEL(@"NSComparisonPredicate Info");
        ADD_ENUM(ComparisonPredicateModifier, [o comparisonPredicateModifier], @"Comparison predicate modifier")
        ADD_SEL_NOT_NULL([o customSelector], @"Custom selector")
        ADD_OBJECT([o leftExpression], @"Left expression")
        ADD_ENUM(PredicateOperatorType, [o predicateOperatorType], @"Predicate operator type")
        ADD_OBJECT([o rightExpression], @"Right expression")
}

- (void)addNSCompoundPredicate:(id)object
{
        NSCompoundPredicate* o = object;
        ADD_CLASS_LABEL(@"NSCompoundPredicate Info")
        ADD_ENUM(CompoundPredicateType, [o compoundPredicateType], @"Compound predicate type")
        ADD_OBJECTS([o subpredicates], @"Subpredicates")
}

- (void)addNSController:(id)object
{
        if ([object isKindOfClass:[NSObjectController class]]) {
                if ([object isKindOfClass:[NSArrayController class]]) {
                        if ([object isKindOfClass:[NSDictionaryController class]]) {
                                NSDictionaryController* o = object;
                                ADD_CLASS_LABEL(@"NSDictionaryController Info");
                                ADD_OBJECTS([o excludedKeys], @"Excluded keys")
                                ADD_OBJECTS([o includedKeys], @"Included keys")
                                ADD_OBJECT([o initialKey], @"Initial key")
                                ADD_OBJECT([o initialValue], @"Initial value")
                                ADD_DICTIONARY([o localizedKeyDictionary], @"Localized key dictionary")
                                ADD_OBJECT_NOT_NIL([o localizedKeyTable], @"Localized key table")
                        }

                        NSArrayController* o = object;
                        ADD_CLASS_LABEL(@"NSArrayController Info");
                        ADD_BOOL([o alwaysUsesMultipleValuesMarker], @"Always uses multiple values marker")
                        ADD_BOOL([o automaticallyRearrangesObjects], @"Automatically rearranges objects")
                        ADD_OBJECTS([o automaticRearrangementKeyPaths], @"Automatic rearrangement key paths")
                        ADD_BOOL([o avoidsEmptySelection], @"Avoids empty selection")
                        ADD_BOOL([o clearsFilterPredicateOnInsertion], @"Clears filter predicate on insertion")
                        ADD_BOOL([o canInsert], @"Can insert")
                        ADD_BOOL([o canSelectNext], @"Can select next")
                        ADD_BOOL([o canSelectPrevious], @"Can select previous")
                        ADD_OBJECT_NOT_NIL([o filterPredicate], @"Filter predicate")
                        ADD_BOOL([o preservesSelection], @"Preserves selection")
                        if ([o selectionIndex] != NSNotFound)
                                ADD_NUMBER([o selectionIndex], @"Selection index")
                        ADD_OBJECT([o selectionIndexes], @"Selection indexes")
                        ADD_BOOL([o selectsInsertedObjects], @"Selects inserted Objects")
                        ADD_OBJECTS([o sortDescriptors], @"Sort descriptors")
                }
                else if ([object isKindOfClass:[NSTreeController class]]) {
                        NSTreeController* o = object;
                        ADD_CLASS_LABEL(@"NSTreeController Info");
                        ADD_BOOL([o alwaysUsesMultipleValuesMarker], @"Always uses multiple values marker")
                        ADD_BOOL([o avoidsEmptySelection], @"Avoids empty selection")
                        ADD_BOOL([o canAddChild], @"Can add child")
                        ADD_BOOL([o canInsert], @"Can insert")
                        ADD_BOOL([o canInsertChild], @"Can insert child")
                        ADD_OBJECT([o childrenKeyPath], @"Children key path")
                        ADD_OBJECT([o countKeyPath], @"Count key path")
                        ADD_OBJECT([o leafKeyPath], @"Leaf key path")
                        ADD_BOOL([o preservesSelection], @"Preserves selection")
                        ADD_OBJECTS([o selectedNodes], @"Selected nodes")
                        ADD_OBJECTS([o selectedObjects], @"Selected objects")
                        ADD_OBJECTS([o selectionIndexPaths], @"Selection index paths")
                        ADD_BOOL([o selectsInsertedObjects], @"Selects inserted Objects")
                        ADD_OBJECTS([o sortDescriptors], @"Sort descriptors")
                }

                NSObjectController* o = object;
                ADD_CLASS_LABEL(@"NSObjectController Info");
                ADD_BOOL([o automaticallyPreparesContent], @"Automatically prepares content")
                ADD_BOOL([o canAdd], @"Can add")
                ADD_BOOL([o canRemove], @"Can remove")
                ADD_OBJECT([o content], @"Content")
                if ([o managedObjectContext] != nil) // Do not work when there is no managedObjectContext associated with the object
                        ADD_OBJECT_NOT_NIL([o defaultFetchRequest], @"Default fetch request")
                ADD_OBJECT_NOT_NIL([o entityName], @"Entity name")
                ADD_OBJECT_NOT_NIL([o fetchPredicate], @"Fetch predicate")
                ADD_BOOL([o isEditable], @"Is editable")
                ADD_OBJECT_NOT_NIL([o managedObjectContext], @"Managed object context")
                ADD_OBJECT([o objectClass], @"Object class")
                ADD_OBJECTS([o selectedObjects], @"Selected objects")
                ADD_OBJECT([o selection], @"Selection")
                ADD_BOOL([o usesLazyFetching], @"Uses lazy fetching")
        }
        else if ([object isKindOfClass:[NSUserDefaultsController class]]) {
                NSUserDefaultsController* o = object;
                ADD_CLASS_LABEL(@"NSUserDefaultsController Info");
                ADD_BOOL([o appliesImmediately], @"Applies immediately")
                ADD_OBJECT([o defaults], @"Defaults")
                ADD_BOOL([o hasUnappliedChanges], @"Has unapplied changes")
                ADD_OBJECT([o initialValues], @"Initial values")
                ADD_OBJECT([o values], @"Values")
        }

        NSController* o = object;
        ADD_CLASS_LABEL(@"NSController Info");
        ADD_BOOL([o isEditing], @"Is editing")
}

- (void)addNSCursor:(id)object
{
        NSCursor* o = object;
        ADD_CLASS_LABEL(@"NSCursor Info");
        ADD_POINT([o hotSpot], @"HotSpot")
        ADD_OBJECT([o image], @"Image")
        ADD_BOOL([o isSetOnMouseEntered], @"Is set on mouse entered")
        ADD_BOOL([o isSetOnMouseExited], @"Is set on mouse exited")
}

- (void)addNSDockTile:(id)object
{
        NSDockTile* o = object;
        ADD_CLASS_LABEL(@"NSDockTile Info");
        ADD_OBJECT([o badgeLabel], @"Badge label")
        ADD_OBJECT([o contentView], @"Content view")
        ADD_OBJECT([o owner], @"Owner")
        ADD_BOOL([o showsApplicationBadge], @"Shows application badge")
        ADD_SIZE([o size], @"Size")
}

- (void)addNSDocument:(id)object
{
        NSDocument* o = object;
        ADD_CLASS_LABEL(@"NSDocument Info");
        ADD_OBJECT_NOT_NIL([o autosavedContentsFileURL], @"Autosaved contents file URL")
        ADD_OBJECT([o autosavingFileType], @"Autosaving file type")
        ADD_OBJECT([o displayName], @"Display name")
        ADD_OBJECT([o fileModificationDate], @"File modification date")
        ADD_BOOL([o fileNameExtensionWasHiddenInLastRunSavePanel], @"File name extension was hidden in last run save panel")
        ADD_OBJECT([o fileType], @"File type")
        ADD_OBJECT([o fileTypeFromLastRunSavePanel], @"File type from last run save panel")
        ADD_OBJECT_NOT_NIL([o fileURL], @"File URL")
        ADD_BOOL([o hasUnautosavedChanges], @"Has unautosaved changes")
        ADD_BOOL([o hasUndoManager], @"Has undo manager")
        ADD_BOOL([o isDocumentEdited], @"Is document edited")
        ADD_BOOL([o keepBackupFile], @"Keep backup file")
        ADD_OBJECT([o fileTypeFromLastRunSavePanel], @"File type from last run save panel")
        ADD_OBJECT([o printInfo], @"Print info")
        ADD_BOOL([o shouldRunSavePanelWithAccessoryView], @"Should run save panel with accessory view")
        ADD_OBJECTS([o windowControllers], @"Window controllers")
        ADD_OBJECT([o windowForSheet], @"Window for sheet")
        ADD_OBJECT([o windowNibName], @"Window nib name")
}

- (void)addNSDocumentController:(id)object
{
        NSDocumentController* o = object;
        ADD_CLASS_LABEL(@"NSDocumentController Info");
        ADD_NUMBER([o autosavingDelay], @"Autosaving delay")
        ADD_OBJECT([o currentDirectory], @"Current directory")
        ADD_OBJECT([o currentDocument], @"Current document")
        ADD_OBJECT([o defaultType], @"Default type")
        ADD_OBJECTS([o documentClassNames], @"Document class names")
        ADD_OBJECTS([o documents], @"Documents")
        ADD_BOOL([o hasEditedDocuments], @"Has edited documents")
        ADD_NUMBER([o maximumRecentDocumentCount], @"Maximum recent document count")
        ADD_OBJECT([o recentDocumentURLs], @"Recent document URLs")
}

- (void)addNSEntityDescription:(id)object
{
        NSEntityDescription* o = object;
        ADD_CLASS_LABEL(@"NSEntityDescription Info");
        ADD_DICTIONARY([o attributesByName], @"Attributes by name")
        ADD_BOOL([o isAbstract], @"Is abstract")
        ADD_OBJECT([o managedObjectClassName], @"Managed object class name")
        ADD_OBJECT([o managedObjectModel], @"Managed object model")
        ADD_OBJECT([o name], @"Name")
        ADD_DICTIONARY([o relationshipsByName], @"Relationships by name")
        if ([[o subentities] count] != 0) {
                ADD_DICTIONARY([o subentitiesByName], @"Subentities by Name")
        }
        ADD_OBJECT([o superentity], @"Superentity")
        ADD_DICTIONARY([o userInfo], @"User info")
}

- (void)addNSEvent:(id)object
{
        NSEvent* o = object;
        NSEventType type = [o type];
        ADD_CLASS_LABEL(@"NSEvent Info");

        if (type == NSTabletPoint || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletPointEventSubtype)) {
                ADD_NUMBER([o absoluteX], @"Absolute x")
                ADD_NUMBER([o absoluteY], @"Absolute y")
                ADD_NUMBER([o absoluteZ], @"Absolute z")
                ADD_ENUM(EventButtonMask, [o buttonMask], @"Button mask")
        }
        if (type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp)
                ADD_NUMBER([o buttonNumber], @"Button number")

        if (type == NSTabletProximity || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletProximityEventSubtype))
                ADD_NUMBER([o capabilityMask], @"Capability mask")

        if (type == NSKeyDown || type == NSKeyUp) {
                ADD_OBJECT([(NSEvent*)o characters], @"Characters")
                ADD_OBJECT([o charactersIgnoringModifiers], @"Characters ignoring modifiers")
        }
        if (type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp)
                ADD_NUMBER([o clickCount], @"Click count")
        if (type == NSAppKitDefined || type == NSSystemDefined || type == NSApplicationDefined) {
                ADD_NUMBER([o data1], @"Data1")
                ADD_NUMBER([o data2], @"Data2")
        }
        if (type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) {
                ADD_NUMBER([o deltaX], @"Delta x")
                ADD_NUMBER([o deltaY], @"Delta y")
                ADD_NUMBER([o deltaZ], @"Delta z")
        }

        if (type == NSTabletPoint || type == NSTabletProximity || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && ([object subtype] == NSTabletProximityEventSubtype || [object subtype] == NSTabletPointEventSubtype)))
                ADD_NUMBER([o deviceID], @"Device ID")
        if (type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel || type == NSMouseEntered || type == NSMouseExited || type == NSCursorUpdate)
                ADD_NUMBER([o eventNumber], @"Event number")
        if (type == NSKeyDown)
                ADD_BOOL([o isARepeat], @"Is a repeat")
        if (type == NSTabletProximity || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletProximityEventSubtype))
                ADD_BOOL([o isEnteringProximity], @"Is entering proximity")
        if (type == NSKeyDown || type == NSKeyUp)
                ADD_NUMBER([o keyCode], @"Key code")
        if (type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel)
                ADD_POINT([o locationInWindow], @"Location in window")
        ADD_ENUM(KeyModifierMask, [o modifierFlags], @"Modifier flags")
        if (type == NSTabletProximity || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletProximityEventSubtype)) {
                ADD_NUMBER([o pointingDeviceID], @"Pointing device ID")
                ADD_NUMBER([o pointingDeviceSerialNumber], @"Pointing device serial number")
                ADD_ENUM(PointingDeviceType, [o pointingDeviceType], @"Pointing device type")
        }
        if (type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel)
                ADD_NUMBER([o pressure], @"Pressure")
        if (type == NSTabletPoint || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletPointEventSubtype))
                ADD_NUMBER([o rotation], @"Rotation")
        if (type == NSAppKitDefined || type == NSSystemDefined || type == NSApplicationDefined || type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel)
                ADD_ENUM(EventSubtype, [o subtype], @"Subtype")
        if (type == NSTabletProximity || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletProximityEventSubtype)) {
                ADD_NUMBER([o systemTabletID], @"System tablet ID")
                ADD_NUMBER([o tabletID], @"Tablet ID")
        }
        if (type == NSTabletPoint || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletPointEventSubtype)) {
                ADD_NUMBER([o tangentialPressure], @"Tangential pressure")
                ADD_POINT([o tilt], @"Tilt")
        }
        ADD_NUMBER([o timestamp], @"Timestamp")
        if (type == NSMouseEntered || type == NSMouseExited || type == NSCursorUpdate) {
                ADD_OBJECT([o trackingArea], @"Tracking area")
                ADD_NUMBER([o trackingNumber], @"Tracking number")
        }
        ADD_ENUM(EventType, [(NSEvent*)o type], @"Type")
        if (type == NSTabletProximity || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletProximityEventSubtype))
                ADD_NUMBER([o uniqueID], @"Unique ID")
        if (type == NSMouseEntered || type == NSMouseExited || type == NSCursorUpdate) {
                void* userData = [o userData];
                if (userData)
                        ADD_POINTER([o userData], @"User data")
        }
        if (type == NSTabletPoint || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletPointEventSubtype))
                ADD_OBJECT([o vendorDefined], @"Vendor defined")
        if (type == NSTabletProximity || ((type == NSLeftMouseDown || type == NSLeftMouseUp || type == NSRightMouseDown || type == NSRightMouseUp || type == NSOtherMouseDown || type == NSOtherMouseUp || type == NSMouseMoved || type == NSLeftMouseDragged || type == NSRightMouseDragged || type == NSOtherMouseDragged || type == NSScrollWheel) && [object subtype] == NSTabletProximityEventSubtype)) {
                ADD_NUMBER([o vendorID], @"Vendor ID")
                ADD_NUMBER([o vendorPointingDeviceType], @"Vendor pointing device type")
        }
        if (type != NSPeriodic)
                ADD_OBJECT([o window], @"Window")
}

- (void)addNSExpression:(id)object
{
        NSExpression* o = object;
        NSArray* arguments = nil;
        id collection = nil;
        id constantValue = nil;
        NSExpressionType expressionType = 0;
        NSString* function = nil;
        NSString* keyPath = nil;
        NSExpression* leftExpression = nil;
        NSExpression* operand = nil;
        NSPredicate* predicate = nil;
        NSExpression* rightExpression = nil;
        NSString* variable = nil;

        BOOL argumentsIsInitialized = NO;
        BOOL collectionIsInitialized = NO;
        BOOL constantValueIsInitialized = NO;
        BOOL expressionTypeIsInitialized = NO;
        BOOL functionIsInitialized = NO;
        BOOL keyPathIsInitialized = NO;
        BOOL leftExpressionIsInitialized = NO;
        BOOL operandIsInitialized = NO;
        BOOL predicateIsInitialized = NO;
        BOOL rightExpressionIsInitialized = NO;
        BOOL variableIsInitialized = NO;

        @try {
                arguments = [o arguments];
                argumentsIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                collection = [o collection];
                collectionIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                constantValue = [o constantValue];
                constantValueIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                expressionType = [o expressionType];
                expressionTypeIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                function = [o function];
                functionIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                keyPath = [o keyPath];
                keyPathIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                leftExpression = [o leftExpression];
                leftExpressionIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                operand = [o operand];
                operandIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                predicate = [o predicate];
                predicateIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                rightExpression = [o rightExpression];
                rightExpressionIsInitialized = YES;
        }
        @catch (id exception) {}
        @try {
                variable = [o variable];
                variableIsInitialized = YES;
        }
        @catch (id exception) {}

        ADD_CLASS_LABEL(@"NSExpression Info");

        if (argumentsIsInitialized)
                ADD_OBJECTS(arguments, @"Arguments");
        if (collectionIsInitialized)
                ADD_OBJECT(collection, @"Collection");
        if (constantValueIsInitialized)
                ADD_OBJECT(constantValue, @"Constant value");
        if (expressionTypeIsInitialized)
                ADD_ENUM(ExpressionType, expressionType, @"Expression type");
        if (functionIsInitialized)
                ADD_OBJECT(function, @"Function");
        if (keyPathIsInitialized)
                ADD_OBJECT(keyPath, @"Key path");
        if (leftExpressionIsInitialized)
                ADD_OBJECT(leftExpression, @"Left expression");
        if (operandIsInitialized)
                ADD_OBJECT(operand, @"Operand");
        if (predicateIsInitialized)
                ADD_OBJECT(predicate, @"Predicate");
        if (rightExpressionIsInitialized)
                ADD_OBJECT(leftExpression, @"Right expression");
        if (variableIsInitialized)
                ADD_OBJECT(variable, @"Variable");
}

- (void)addNSFetchRequest:(id)object
{
        NSFetchRequest* o = object;
        ADD_CLASS_LABEL(@"NSFetchRequest Info");
        ADD_OBJECTS([o affectedStores], @"Affected stores")
        ADD_OBJECT([o entity], @"Entity")
        ADD_NUMBER([o fetchLimit], @"Fetch limit")
        ADD_BOOL([o includesPropertyValues], @"Includes property values")
        ADD_BOOL([o includesSubentities], @"Includes bubentities")
        ADD_OBJECT([o predicate], @"Predicate")
        ADD_OBJECTS([o relationshipKeyPathsForPrefetching], @"Relationship key paths for prefetching")
        ADD_ENUM(FetchRequestResultType, [o resultType], @"Result type")
        ADD_BOOL([o returnsObjectsAsFaults], @"Returns objects as faults")
        ADD_OBJECTS([o sortDescriptors], @"Sort descriptors")
}

- (void)addNSFileWrapper:(id)object
{
        NSFileWrapper* o = object;
        ADD_CLASS_LABEL(@"NSFileWrapper Info");
        ADD_DICTIONARY([o fileAttributes], @"File attributes")
        ADD_OBJECT([o filename], @"Filename")
        ADD_OBJECT_NOT_NIL([o icon], @"Icon")
        ADD_BOOL([o isDirectory], @"Is directory")
        ADD_BOOL([o isRegularFile], @"Is regularFile")
        ADD_BOOL([o isSymbolicLink], @"Is symbolic link")
        ADD_OBJECT_NOT_NIL([o preferredFilename], @"Preferred filename")
        if ([o isSymbolicLink])
                ADD_OBJECT_NOT_NIL([o symbolicLinkDestination], @"Symbolic link destination")
}

- (void)addNSFont:(id)object
{
        NSFont* o = object;
        ADD_CLASS_LABEL(@"NSFont Info");
        ADD_NUMBER([o ascender], @"Ascender")
        ADD_RECT([o boundingRectForFont], @"Bounding rect for font")
        ADD_NUMBER([o capHeight], @"Cap height")
        ADD_OBJECT([o coveredCharacterSet], @"Covered character set")
        ADD_NUMBER([o descender], @"Descender")
        ADD_OBJECT([o displayName], @"Display name")
        ADD_OBJECT([o familyName], @"Family name")
        ADD_OBJECT([o fontDescriptor], @"Font descriptor")
        ADD_OBJECT([o fontName], @"Font name")
        ADD_BOOL([o isFixedPitch], @"Is fixedPitch")
        ADD_NUMBER([o italicAngle], @"Italic angle")
        ADD_NUMBER([o leading], @"Leading")

        const CGFloat* matrix = [o matrix];
        NSString* matrixString = [NSString stringWithFormat:@"[%g %g %g %g %g %g]", (double)(matrix[0]), (double)(matrix[1]), (double)(matrix[2]), (double)(matrix[3]), (double)(matrix[4]), (double)(matrix[5])];
        [view addObject:matrixString withLabel:@"Matrix" toMatrix:m leaf:YES classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject indentationLevel:0];

        ADD_SIZE([o maximumAdvancement], @"Maximum advancement")
        ADD_ENUM(StringEncoding, [o mostCompatibleStringEncoding], @"Most compatible string encoding")
        ADD_NUMBER([o numberOfGlyphs], @"Number of glyphs")
        ADD_NUMBER([o pointSize], @"Point size")
        ADD_OBJECT([o printerFont], @"Printer font")
        ADD_ENUM(FontRenderingMode, [o renderingMode], @"Rendering mode")
        ADD_OBJECT_NOT_NIL([o screenFont], @"Screen font")
        ADD_NUMBER([o underlinePosition], @"Underline position")
        ADD_NUMBER([o underlineThickness], @"Underline thickness")
        ADD_NUMBER([o xHeight], @"xHeight")
}

- (void)addNSFontDescriptor:(id)object
{
        NSFontDescriptor* o = object;
        ADD_CLASS_LABEL(@"NSFontDescriptor Info");
        ADD_DICTIONARY([o fontAttributes], @"Font attributes")
        ADD_OBJECT([o matrix], @"Matrix")
        ADD_NUMBER([o pointSize], @"Point size")
        ADD_OBJECT([o postscriptName], @"Postscript name")
        ADD_NUMBER([o symbolicTraits], @"Symbolic traits")
}

- (void)addNSFontManager:(id)object
{
        NSFontManager* o = object;
        ADD_CLASS_LABEL(@"NSFontManager Info");
        ADD_SEL([o action], @"Action")
        ADD_OBJECTS([o availableFontFamilies], @"Available font families")
        ADD_OBJECTS([o availableFonts], @"Available fonts")
        ADD_OBJECTS([o collectionNames], @"Collection names")
        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
        ADD_BOOL([o isEnabled], @"Is enabled")
        ADD_BOOL([o isMultiple], @"IsMultiple")
        ADD_OBJECT([o selectedFont], @"Selected font")
        ADD_OBJECT([o target], @"Target")
}

- (void)addNSGlyphInfo:(id)object
{
        NSGlyphInfo* o = object;
        ADD_CLASS_LABEL(@"NSGlyphInfo Info");
        ADD_ENUM(CharacterCollection, [o characterCollection], @"Character collection")
        if ([o characterIdentifier])
                ADD_NUMBER([o characterIdentifier], @"Character identifier");
        ADD_OBJECT_NOT_NIL([o glyphName], @"Glyph name")
}

- (void)addNSGlyphGenerator:(id)object
{
        //NSGlyphGenerator *o = object;
        //ADD_CLASS_LABEL(@"NSGlyphGenerator Info");
}

- (void)addNSGradient:(id)object
{
        NSGradient* o = object;
        ADD_CLASS_LABEL(@"NSGradient Info");
        ADD_OBJECT_NOT_NIL([o colorSpace], @"Color space")
        ADD_NUMBER([o numberOfColorStops], @"Number of color stops")
}


- (void)addNSGraphicsContext:(id)object
{
        NSGraphicsContext* o = object;
        ADD_CLASS_LABEL(@"NSGraphicsContext Info");
        ADD_DICTIONARY([o attributes], @"Attributes")
        ADD_ENUM(ColorRenderingIntent, [o colorRenderingIntent], @"Color rendering intent")
        ADD_ENUM(CompositingOperation, [o compositingOperation], @"Compositing operation")
        ADD_POINTER([o graphicsPort], @"Graphics port")
        ADD_ENUM(ImageInterpolation, [o imageInterpolation], @"Image interpolation")
        ADD_BOOL([o isDrawingToScreen], @"Is drawing to screen")
        ADD_BOOL([o isFlipped], @"Is flipped")
        ADD_POINT([o patternPhase], @"Pattern phase")
        ADD_BOOL([o shouldAntialias], @"Should antialias")
}

- (void)addNSImage:(id)object
{
        NSImage* o = object;
        ADD_CLASS_LABEL(@"NSImage Info");
        ADD_RECT([o alignmentRect], @"Alignment rect")
        ADD_OBJECT([o backgroundColor], @"Background color")
        ADD_BOOL([o cacheDepthMatchesImageDepth], @"Cache depth matches image depth")
        ADD_ENUM(ImageCacheMode, [o cacheMode], @"Cache mode")
        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
        ADD_BOOL([o isCachedSeparately], @"Is cached separately")
        ADD_BOOL([o isDataRetained], @"Is data retained")
        ADD_BOOL([o isFlipped], @"Is flipped")
        ADD_BOOL([o isTemplate], @"Is template")
        ADD_BOOL([o isValid], @"Is valid")
        ADD_BOOL([o matchesOnMultipleResolution], @"Matches on multiple resolution")
        ADD_OBJECT_NOT_NIL([o name], @"Name")
        ADD_BOOL([o prefersColorMatch], @"Prefers color match")
        ADD_OBJECTS([o representations], @"Representations")
        ADD_BOOL([o scalesWhenResized], @"Scales when resized")
        ADD_SIZE([o size], @"Size")
        ADD_BOOL([o usesEPSOnResolutionMismatch], @"Uses EPS on resolution mismatch")
}

- (void)addNSImageRep:(id)object
{
        if ([object isKindOfClass:[NSBitmapImageRep class]]) {
                NSBitmapImageRep* o = object;
                ADD_CLASS_LABEL(@"NSBitmapImageRep Info");
                ADD_ENUM(BitmapFormat, [o bitmapFormat], @"Bitmap format")
                ADD_NUMBER([o bitsPerPixel], @"Bits per pixel")
                ADD_NUMBER([o bytesPerPlane], @"Bytes per plane")
                ADD_NUMBER([o bytesPerRow], @"Bytes per row")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageColorSyncProfileData], @"ColorSync profile data")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageCompressionFactor], @"Compression factor")
                {
                        id compressionMethod = [o valueForProperty:NSImageCompressionMethod];
                        if ([compressionMethod isKindOfClass:[NSNumber class]])
                                ADD_ENUM(TIFFCompression, [[o valueForProperty:NSImageCompressionMethod] longValue], @"Compression method")
                }
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageCurrentFrame], @"Current frame")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageCurrentFrameDuration], @"Current frame duration")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageDitherTransparency], @"Dither transparency")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageEXIFData], @"EXIF data")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageFallbackBackgroundColor], @"Fallback background color")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageFrameCount], @"Frame count")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageGamma], @"Gamma")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageInterlaced], @"Interlaced")
                ADD_BOOL([o isPlanar], @"Is planar")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageLoopCount], @"Loop count")
                ADD_NUMBER([o numberOfPlanes], @"Number of planes")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageProgressive], @"Progressive")
                ADD_OBJECT_NOT_NIL([o valueForProperty:NSImageRGBColorTable], @"RGB color table")
                ADD_NUMBER([o samplesPerPixel], @"Samples per pixel")
        }
        else if ([object isKindOfClass:[NSCIImageRep class]]) {
                NSCIImageRep* o = object;
                ADD_CLASS_LABEL(@"NSCIImageRep Info");
                ADD_OBJECT([o CIImage], @"CIImage")
        }
        else if ([object isKindOfClass:[NSCustomImageRep class]]) {
                NSCustomImageRep* o = object;
                ADD_CLASS_LABEL(@"NSCustomImageRep Info");
                ADD_OBJECT([o delegate], @"Delegate")
                ADD_SEL([o drawSelector], @"Draw selector")
        }
        else if ([object isKindOfClass:[NSEPSImageRep class]]) {
                NSEPSImageRep* o = object;
                ADD_CLASS_LABEL(@"NSEPSImageRep Info");
                ADD_RECT([o boundingBox], @"Bounding box")
        }
        else if ([object isKindOfClass:[NSPDFImageRep class]]) {
                NSPDFImageRep* o = object;
                ADD_CLASS_LABEL(@"NSPDFImageRep Info");
                ADD_RECT([o bounds], @"Bounding box")
                ADD_NUMBER([o currentPage], @"Current page")
                ADD_NUMBER([o pageCount], @"Page count")
        }
        else if ([object isKindOfClass:[NSPICTImageRep class]]) {
                NSPICTImageRep* o = object;
                ADD_CLASS_LABEL(@"NSPICTImageRep Info");
                ADD_RECT([o boundingBox], @"Bounding box")
        }

        NSImageRep* o = object;
        ADD_CLASS_LABEL(@"NSImageRep Info");
        ADD_NUMBER([o bitsPerSample], @"Bits per sample")
        ADD_OBJECT([o colorSpaceName], @"Color space name")
        ADD_BOOL([o hasAlpha], @"Has alpha")
        ADD_BOOL([o isOpaque], @"Is opaque")
        ADD_NUMBER([o pixelsHigh], @"Pixels high")
        ADD_NUMBER([o pixelsWide], @"Pixels wide")
        ADD_SIZE([o size], @"Size")
}

- (void)addNSLayoutManager:(id)object
{
        NSLayoutManager* o = object;
        ADD_CLASS_LABEL(@"NSLayoutManager Info");
        ADD_BOOL([o allowsNonContiguousLayout], @"Allows non contiguous layout")
        ADD_BOOL([o backgroundLayoutEnabled], @"Background layout enabled")
        ADD_ENUM(ImageScaling, [o defaultAttachmentScaling], @"Default attachment scaling")
        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
        ADD_RECT([o extraLineFragmentRect], @"Extra line fragment rect")
        ADD_OBJECT_NOT_NIL([o extraLineFragmentTextContainer], @"Extra line fragment text container")
        ADD_RECT([o extraLineFragmentUsedRect], @"Extra line fragment used rect")
        ADD_OBJECT([o firstTextView], @"First text view")
        ADD_NUMBER([o firstUnlaidCharacterIndex], @"First unlaid character index")
        ADD_NUMBER([o firstUnlaidGlyphIndex], @"First unlaid glyph index")
        ADD_OBJECT([o glyphGenerator], @"Glyph generator")
        ADD_BOOL([o hasNonContiguousLayout], @"Has non contiguous layout")
        ADD_NUMBER([o hyphenationFactor], @"Hyphenation factor")
        ADD_ENUM(GlyphStorageLayoutOptions, [o layoutOptions], @"Layout options")
        ADD_BOOL([o showsControlCharacters], @"Shows control characters")
        ADD_BOOL([o showsInvisibleCharacters], @"Shows invisible characters")
        ADD_OBJECTS([o textContainers], @"Text containers")
        ADD_OBJECT([o textStorage], @"Text storage")
        ADD_OBJECT([o textViewForBeginningOfSelection], @"Text view for beginning of selection")
        ADD_OBJECT([o typesetter], @"Typesetter")
        ADD_ENUM(TypesetterBehavior, [o typesetterBehavior], @"Typesetter behavior")
        ADD_BOOL([o usesFontLeading], @"Uses font leading")
        ADD_BOOL([o usesScreenFonts], @"Uses screen fonts")
}

- (void)addNSManagedObjectContext:(id)object
{
        NSManagedObjectContext* o = object;
        ADD_CLASS_LABEL(@"NSManagedObjectContext Info");
        ADD_OBJECT([o deletedObjects], @"Deleted objects")
        ADD_BOOL([o hasChanges], @"Has changes")
        ADD_OBJECT([o insertedObjects], @"Inserted objects")
        ADD_ENUM(MergePolicy, [o mergePolicy], @"Merge policy")
        ADD_OBJECT([o persistentStoreCoordinator], @"Persistent store coordinator")
        ADD_BOOL([o propagatesDeletesAtEndOfEvent], @"Propagates deletes at end of event")
        ADD_OBJECT([o registeredObjects], @"Registered objects")
        ADD_BOOL([o retainsRegisteredObjects], @"Retains registered objects")
        ADD_NUMBER([o stalenessInterval], @"Staleness interval")
        ADD_BOOL([o tryLock], @"Try lock")
        ADD_OBJECT([o undoManager], @"Undo manager")
        ADD_OBJECT([o updatedObjects], @"Updated objects")
}

- (void)addNSManagedObjectID:(id)object
{
        NSManagedObjectID* o = object;
        ADD_CLASS_LABEL(@"NSManagedObjectID Info");
        ADD_OBJECT([o entity], @"Entity")
        ADD_BOOL([o isTemporaryID], @"Is temporary ID")
        ADD_OBJECT([o persistentStore], @"Persistent store")
        ADD_OBJECT([o URIRepresentation], @"URI representation")
}

- (void)addNSManagedObjectModel:(id)object
{
        NSManagedObjectModel* o = object;
        ADD_CLASS_LABEL(@"NSManagedObjectModel Info");
        ADD_OBJECTS([o configurations], @"Configurations")
        ADD_DICTIONARY([o entitiesByName], @"Entities by name")
        ADD_DICTIONARY([o fetchRequestTemplatesByName], @"Fetch request templates by name")
        ADD_OBJECTS([[o versionIdentifiers] allObjects], @"Version identifiers")
}

- (void)addNSMenu:(id)object
{
        NSMenu* o = object;
        ADD_CLASS_LABEL(@"NSMenu Info");
        ADD_BOOL([o autoenablesItems], @"Autoenables Items")
        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
        ADD_OBJECT_NOT_NIL([o highlightedItem], @"Highlighted item")
        ADD_BOOL([o isTornOff], @"Is torn off")
        ADD_OBJECTS([o itemArray], @"Items")
        ADD_BOOL([o menuChangedMessagesEnabled], @"Menu changed messages enabled")
        ADD_BOOL([o showsStateColumn], @"Shows state column")
        ADD_OBJECT_NOT_NIL([o supermenu], @"Supermenu")
        ADD_OBJECT([o title], @"Title")
}

- (void)addNSMenuItem:(id)object
{
        NSMenuItem* o = object;
        ADD_CLASS_LABEL(@"NSMenuItem Info")
        ADD_SEL([o action], @"Action")
        ADD_OBJECT_NOT_NIL([o attributedTitle], @"Attributed title")
        ADD_BOOL([o hasSubmenu], @"Has submenu")
        ADD_OBJECT_NOT_NIL([o image], @"Image")
        ADD_NUMBER([o indentationLevel], @"Indentation level")
        ADD_BOOL([o isAlternate], @"Is alternate")
        ADD_BOOL([o isEnabled], @"Is enabled")
        ADD_BOOL([o isHidden], @"Is hidden")
        ADD_BOOL([o isHiddenOrHasHiddenAncestor], @"Is hidden or has hidden ancestor")
        ADD_BOOL([o isHighlighted], @"Is highlighted")
        ADD_BOOL([o isSeparatorItem], @"Is separatorItem")
        ADD_OBJECT([o keyEquivalent], @"Key equivalent")
        ADD_ENUM(KeyModifierMask, [o keyEquivalentModifierMask], @"Key equivalent modifier mask")
        ADD_OBJECT([o menu], @"Menu")
        ADD_OBJECT_NOT_NIL([o mixedStateImage], @"Mixed state image")
        ADD_OBJECT_NOT_NIL([o offStateImage], @"Off state image")
        ADD_OBJECT_NOT_NIL([o onStateImage], @"On state image")
        ADD_OBJECT_NOT_NIL([o representedObject], @"Represented object")
        ADD_ENUM(CellStateValue, [o state], @"State")
        ADD_OBJECT_NOT_NIL([o submenu], @"Submenu")
        ADD_NUMBER([o tag], @"Tag")
        ADD_OBJECT_NOT_NIL([o target], @"Target")
        ADD_OBJECT([o title], @"Title")
        ADD_OBJECT_NOT_NIL([o toolTip], @"Tool tip")
        ADD_OBJECT([o userKeyEquivalent], @"User key equivalent")
        ADD_OBJECT_NOT_NIL([o view], @"View")
}

- (void)addNSOpenGLContext:(id)object
{
        NSOpenGLContext* o = object;
        ADD_CLASS_LABEL(@"NSOpenGLContext Info");
        ADD_POINTER([o CGLContextObj], @"CGL context obj")
        ADD_NUMBER([o currentVirtualScreen], @"Current virtual screen")
        ADD_OBJECT_NOT_NIL([o pixelBuffer], @"Pixel buffer")
        ADD_NUMBER([o pixelBufferCubeMapFace], @"Pixel buffer cube map face")
        ADD_NUMBER([o pixelBufferMipMapLevel], @"Pixel buffer mipmap level")
        ADD_OBJECT_NOT_NIL([o view], @"View")
}

- (void)addNSOpenGLPixelBuffer:(id)object
{
        NSOpenGLPixelBuffer* o = object;
        ADD_CLASS_LABEL(@"NSOpenGLPixelBuffer Info");
        ADD_NUMBER([o pixelsHigh], @"Pixels high")
        ADD_NUMBER([o pixelsWide], @"Pixels wide")
        ADD_NUMBER([o textureInternalFormat], @"Texture internal format")
        ADD_NUMBER([o textureMaxMipMapLevel], @"Texture max mipmap level")
        ADD_NUMBER([o textureTarget], @"Texture target")
}

- (void)addNSOpenGLPixelFormat:(id)object
{
        NSOpenGLPixelFormat* o = object;
        ADD_CLASS_LABEL(@"NSOpenGLPixelFormat Info");
        ADD_POINTER([o CGLPixelFormatObj], @"CGL pixel format obj")
        ADD_NUMBER([o numberOfVirtualScreens], @"Number of virtual screens")
}

- (void)addNSPageLayout:(id)object
{
        NSPageLayout* o = object;

        if ([[o accessoryControllers] count] > 0 || [o printInfo] != nil) {
                ADD_CLASS_LABEL(@"NSPageLayout Info");
                ADD_OBJECTS([o accessoryControllers], @"Accessory controllers")
                ADD_OBJECT_NOT_NIL([o printInfo], @"Print info")
        }
}

- (void)addNSParagraphStyle:(id)object
{
        NSParagraphStyle* o = object;
        ADD_CLASS_LABEL(@"NSParagraphStyle Info")
        ADD_ENUM(TextAlignment, [o alignment], @"Alignment")
        ADD_ENUM(WritingDirection, [o baseWritingDirection], @"Base writing direction")
        ADD_NUMBER([o defaultTabInterval], @"Default tab interval")
        ADD_NUMBER([o firstLineHeadIndent], @"First line head indent")
        ADD_NUMBER([o headerLevel], @"HeaderLevel")
        ADD_NUMBER([o headIndent], @"Head indent")
        ADD_NUMBER([o hyphenationFactor], @"hyphenationFactor")
        ADD_ENUM(LineBreakMode, [o lineBreakMode], @"Line break mode")
        ADD_NUMBER([o lineHeightMultiple], @"Line height multiple")
        ADD_NUMBER([o lineSpacing], @"Line spacing")
        ADD_NUMBER([o maximumLineHeight], @"Maximum line height")
        ADD_NUMBER([o minimumLineHeight], @"Minimum line height")
        ADD_NUMBER([o paragraphSpacing], @"Paragraph spacing")
        ADD_NUMBER([o paragraphSpacingBefore], @"Paragraph spacing before")
        ADD_OBJECTS([o tabStops], @"Tab stops")
        ADD_NUMBER([o tailIndent], @"Tail indent")
        ADD_OBJECTS([o textBlocks], @"Text blocks")
        ADD_OBJECTS([o textLists], @"Text lists")
        ADD_NUMBER([o tighteningFactorForTruncation], @"Tightening factor for truncation")
}

- (void)addNSPersistentStoreCoordinator:(id)object
{
        NSPersistentStoreCoordinator* o = object;
        ADD_CLASS_LABEL(@"NSPersistentStoreCoordinator Info")
        ADD_OBJECT([o managedObjectModel], @"Managed object model")
        ADD_OBJECTS([o persistentStores], @"Persistent stores")
}

- (void)addNSPredicateEditorRowTemplate:(id)object
{
        NSPredicateEditorRowTemplate* o = object;
        ADD_CLASS_LABEL(@"NSPredicateEditorRowTemplate Info")
        ADD_OBJECTS([o compoundTypes], @"Compound types")
        ADD_OBJECTS([o leftExpressions], @"Left expressions")
        ADD_ENUM(ComparisonPredicateModifier, [o modifier], @"Modifier")
        ADD_OBJECTS([o operators], @"Operators")
        ADD_ENUM(ComparisonPredicateOptions, [o options], @"Options")
        ADD_ENUM(AttributeType, [o rightExpressionAttributeType], @"Right expression attribute type")
        ADD_OBJECTS([o rightExpressions], @"Right expressions")
        ADD_OBJECTS([o templateViews], @"Template views")
}

- (void)addNSPropertyDescription:(id)object
{
        if ([object isKindOfClass:[NSAttributeDescription class]]) {
                NSAttributeDescription* o = object;
                ADD_CLASS_LABEL(@"NSAttributeDescription Info")
                ADD_ENUM(AttributeType, [o attributeType], @"Attribute type")
                ADD_OBJECT([o attributeValueClassName], @"Attribute value class name")
                ADD_OBJECT([o defaultValue], @"Default value")

                if ([o attributeType] == NSTransformableAttributeType)
                        ADD_OBJECT([o valueTransformerName], @"Value transformer name")
        }
        else if ([object isKindOfClass:[NSFetchedPropertyDescription class]]) {
                NSFetchedPropertyDescription* o = object;
                ADD_CLASS_LABEL(@"NSFetchedPropertyDescription Info")
                ADD_OBJECT([o fetchRequest], @"Fetch request")
        }
        else if ([object isKindOfClass:[NSRelationshipDescription class]]) {
                NSRelationshipDescription* o = object;
                ADD_CLASS_LABEL(@"NSRelationshipDescription Info")
                ADD_ENUM(DeleteRule, [o deleteRule], @"Delete rule")
                ADD_OBJECT([o destinationEntity], @"Destination entity")
                ADD_OBJECT([o inverseRelationship], @"Inverse relationship")
                ADD_BOOL([o isToMany], @"Is to many")
                ADD_NUMBER([o maxCount], @"Max count")
                ADD_NUMBER([o minCount], @"Min count")
        }

        NSPropertyDescription* o = object;
        ADD_CLASS_LABEL(@"NSPropertyDescription Info")
        ADD_OBJECT([o entity], @"Entity")
        ADD_BOOL([o isIndexed], @"Is indexed")
        ADD_BOOL([o isOptional], @"Is optional")
        ADD_BOOL([o isTransient], @"Is transient")
        ADD_OBJECT([o name], @"Name")
        ADD_DICTIONARY([o userInfo], @"User info")
        ADD_OBJECTS([o validationPredicates], @"Validation predicates")
        ADD_OBJECTS([o validationWarnings], @"Validation warnings")
}

- (void)addNSResponder:(id)object
{
        if ([object isKindOfClass:[NSApplication class]]) {
                NSApplication* o = object;
                ADD_CLASS_LABEL(@"NSApplication Info")
                ADD_OBJECT_NOT_NIL([o applicationIconImage], @"Application icon image")
                ADD_OBJECT_NOT_NIL([o context], @"Context")
                ADD_OBJECT_NOT_NIL([o currentEvent], @"Current event")
                ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                ADD_OBJECT_NOT_NIL([o dockTile], @"Dock tile")
                ADD_BOOL([o isActive], @"Is active")
                ADD_BOOL([o isHidden], @"Is hidden")
                ADD_BOOL([o isRunning], @"Is running")
                ADD_OBJECT_NOT_NIL([o keyWindow], @"Key window")
                ADD_OBJECT_NOT_NIL([o mainMenu], @"Main menu")
                ADD_OBJECT_NOT_NIL([o mainWindow], @"Main window")
                ADD_OBJECT_NOT_NIL([o modalWindow], @"Modal window")
                ADD_OBJECTS([o orderedDocuments], @"Ordered documents")
                ADD_OBJECTS([o orderedWindows], @"Ordered windows")
                ADD_OBJECT_NOT_NIL([o servicesMenu], @"Services menu")
                ADD_OBJECT_NOT_NIL([o servicesProvider], @"Services provider")
                ADD_OBJECTS([o windows], @"Windows")
                ADD_OBJECT_NOT_NIL([o windowsMenu], @"Windows menu")
        }
        else if ([object isKindOfClass:[NSDrawer class]]) {
                NSDrawer* o = object;
                ADD_CLASS_LABEL(@"NSDrawer Info");
                ADD_SIZE([o contentSize], @"Content size")
                ADD_OBJECT([o contentView], @"Content view")
                ADD_OBJECT([o delegate], @"Delegate")
                ADD_ENUM(RectEdge, [o edge], @"Edge")
                ADD_NUMBER([o leadingOffset], @"Leading offset")
                ADD_SIZE([o maxContentSize], @"Max content size")
                ADD_SIZE([o minContentSize], @"Min content size")
                ADD_OBJECT([o parentWindow], @"Parent window")
                ADD_ENUM(RectEdge, [o preferredEdge], @"Preferred edge")
                ADD_ENUM(DrawerState, [o state], @"State")
                ADD_NUMBER([o trailingOffset], @"Trailing offset")
        }
        else if ([object isKindOfClass:[NSView class]]) {
                [self processNSView:object];
        }

        if ([object isKindOfClass:[NSViewController class]]) {
                NSViewController* o = object;
                ADD_CLASS_LABEL(@"NSViewController Info")
                ADD_OBJECT_NOT_NIL([o nibBundle], @"Nib bundle")
                ADD_OBJECT_NOT_NIL([o nibName], @"Nib name")
                ADD_OBJECT_NOT_NIL([o representedObject], @"Represented object")
                ADD_OBJECT_NOT_NIL([o title], @"Title")
                ADD_OBJECT_NOT_NIL([o view], @"View")
        }
        else if ([object isKindOfClass:[NSWindow class]]) {
                [self processNSWindow:object];
        }
        else if ([object isKindOfClass:[NSWindowController class]]) {
                NSWindowController* o = object;
                ADD_CLASS_LABEL(@"NSWindowController Info");
                ADD_OBJECT([o document], @"Document")
                ADD_BOOL([o isWindowLoaded], @"Is window loaded")
                ADD_OBJECT([o owner], @"Owner")
                ADD_BOOL([o shouldCascadeWindows], @"Should cascade windows")
                ADD_BOOL([o shouldCloseDocument], @"Should close document")
                if ([o isWindowLoaded])
                        ADD_OBJECT([o window], @"Window")
                ADD_OBJECT([o windowFrameAutosaveName], @"Window frame autosave name")
                ADD_OBJECT([o windowNibName], @"Window nib name")
                ADD_OBJECT([o windowNibPath], @"Window nib path")
        }

        NSResponder* o = object;
        ADD_CLASS_LABEL(@"NSResponder Info")
        ADD_BOOL([o acceptsFirstResponder], @"Accepts first responder")

        @try {
                [view addObject:[o menu] withLabel:@"Menu" toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
                // The menu method might raise if not implemented in the actual NSResponder subclass
        }
        @catch (id exception) {}

        if ([o nextResponder]) {
                NSResponder* responder = o;
                NSMutableArray* responders = [NSMutableArray array];
                while ((responder = [responder nextResponder]))
                        [responders addObject:responder];
                [view addObjects:responders withLabel:@"Next responders" toMatrix:m classLabel:classLabel selectedClassLabel:selectedClassLabel selectedLabel:selectedLabel selectedObject:selectedObject];
        }

        ADD_OBJECT([o undoManager], @"Undo Manager")
}

- (void)addNSRulerMarker:(id)object
{
        NSRulerMarker* o = object;
        ADD_CLASS_LABEL(@"NSRulerMarker Info");
        ADD_OBJECT([o image], @"Image")
        ADD_POINT([o imageOrigin], @"Image origin")
        ADD_RECT([o imageRectInRuler], @"Image rect in ruler")
        ADD_BOOL([o isDragging], @"Is dragging")
        ADD_BOOL([o isMovable], @"Is movable")
        ADD_BOOL([o isRemovable], @"Is removable")
        ADD_NUMBER([o markerLocation], @"Marker location")
        ADD_OBJECT([o representedObject], @"Represented object")
        ADD_OBJECT([o ruler], @"Ruler")
        ADD_NUMBER([o thicknessRequiredInRuler], @"Thickness required in ruler")
}

- (void)addNSScreen:(id)object
{
        NSScreen* o = object;
        ADD_CLASS_LABEL(@"NSScreen Info");
        ADD_NUMBER([o depth], @"Depth")
        ADD_DICTIONARY([o deviceDescription], @"Device description")
        ADD_RECT([o frame], @"Frame")
        ADD_NUMBER([o userSpaceScaleFactor], @"User space scale factor")
        ADD_RECT([o visibleFrame], @"Visible frame")
}

- (void)addNSShadow:(id)object
{
        NSShadow* o = object;
        ADD_CLASS_LABEL(@"NSShadow Info");
        ADD_NUMBER([o shadowBlurRadius], @"Shadow blur radius")
        ADD_OBJECT([o shadowColor], @"Shadow color")
        ADD_SIZE([o shadowOffset], @"Shadow offset")
}

- (void)addNSStatusBar:(id)object
{
        NSStatusBar* o = object;
        ADD_CLASS_LABEL(@"NSStatusBar Info");
        ADD_BOOL([o isVertical], @"Is vertical")
        ADD_NUMBER([o thickness], @"Thickness")
}

- (void)addNSStatusItem:(id)object
{
        NSStatusItem* o = object;
        ADD_CLASS_LABEL(@"NSStatusItem Info");
        ADD_SEL([o action], @"Action")
        ADD_OBJECT_NOT_NIL([o alternateImage], @"Alternate image")
        ADD_OBJECT_NOT_NIL([o attributedTitle], @"Attributed title")
        ADD_SEL([o doubleAction], @"Double action")
        ADD_BOOL([o highlightMode], @"Highlight mode")
        ADD_OBJECT_NOT_NIL([o image], @"Image")
        ADD_BOOL([o isEnabled], @"Is enabled")
        ADD_ENUM(StatusItemLength, [o length], @"Length")
        ADD_OBJECT_NOT_NIL([o menu], @"Menu")
        ADD_OBJECT([o statusBar], @"Status bar")
        ADD_OBJECT([o target], @"Target")
        ADD_OBJECT_NOT_NIL([o title], @"Title")
        ADD_OBJECT_NOT_NIL([o toolTip], @"Tool tip")
        ADD_OBJECT_NOT_NIL([o view], @"View")
}

- (void)addNSTabViewItem:(id)object
{
        NSTabViewItem* o = object;
        ADD_CLASS_LABEL(@"NSTabViewItem Info");
        ADD_OBJECT([o color], @"Color")
        ADD_OBJECT([(NSTabViewItem*)o identifier], @"Identifier")
        ADD_OBJECT([o initialFirstResponder], @"Initial first responder")
        ADD_OBJECT([o label], @"Label")
        ADD_ENUM(TabState, [o tabState], @"Tab state")
        ADD_OBJECT([o tabView], @"Parent tab view")
        ADD_OBJECT([o view], @"View")
}

- (void)addNSTableColumn:(id)object
{
        NSTableColumn* o = object;
        ADD_CLASS_LABEL(@"NSTableColumn Info");
        ADD_OBJECT([o dataCell], @"Data cell")
        ADD_OBJECT([o headerCell], @"Header cell")
        ADD_OBJECT_NOT_NIL([o headerToolTip], @"Header tool tip")
        ADD_OBJECT([(NSTableColumn*)o identifier], @"Identifier")
        ADD_BOOL([o isEditable], @"Is editable")
        ADD_BOOL([o isHidden], @"Is hidden")
        ADD_NUMBER([o maxWidth], @"Max width")
        ADD_NUMBER([o minWidth], @"Min width")
        ADD_ENUM(TableColumnResizingOptions, [o resizingMask], @"Resizing mask")
        ADD_OBJECT_NOT_NIL([o sortDescriptorPrototype], @"Sort descriptor prototype")
        ADD_OBJECT([o tableView], @"Table view")
        ADD_NUMBER([o width], @"Width")
}

- (void)addNSTextAttachment:(id)object
{
        NSTextAttachment* o = object;
        ADD_CLASS_LABEL(@"NSTextAttachment Info");
        ADD_OBJECT([o attachmentCell], @"Attachment cell")
        ADD_OBJECT([o fileWrapper], @"File wrapper")
}

- (void)addNSTextBlock:(id)object
{
        if ([object isKindOfClass:[NSTextTableBlock class]]) {
                NSTextTableBlock* o = object;
                ADD_CLASS_LABEL(@"NSTextTableBlock Info");
                ADD_NUMBER([o columnSpan], @"Column span")
                ADD_NUMBER([o rowSpan], @"Row span")
                ADD_NUMBER([o startingColumn], @"Starting column")
                ADD_NUMBER([o startingRow], @"Starting row")
                ADD_OBJECT([o table], @"Table")
        }
        else if ([object isKindOfClass:[NSTextTable class]]) {
                NSTextTable* o = object;
                ADD_CLASS_LABEL(@"NSTextTable Info");
                ADD_BOOL([o collapsesBorders], @"Collapses borders")
                ADD_BOOL([o hidesEmptyCells], @"Hides empty cells")
                ADD_ENUM(TextTableLayoutAlgorithm, [o layoutAlgorithm], @"Layout algorithm")
                ADD_NUMBER([o numberOfColumns], @"Number of columns")
        }

        NSTextBlock* o = object;
        ADD_CLASS_LABEL(@"NSTextBlock Info");
        ADD_OBJECT([o backgroundColor], @"Background color")
        ADD_NUMBER([o contentWidth], @"Content width")
        ADD_ENUM(TextBlockValueType, [o contentWidthValueType], @"Content width value type")
        ADD_ENUM(TextBlockVerticalAlignment, [o verticalAlignment], @"Vertical alignment")
}

- (void)addNSTextContainer:(id)object
{
        NSTextContainer* o = object;
        ADD_CLASS_LABEL(@"NSTextContainer Info");
        ADD_SIZE([o containerSize], @"Container size")
        ADD_BOOL([o heightTracksTextView], @"Height tracks text view")
        ADD_BOOL([o isSimpleRectangularTextContainer], @"Is simple rectangular text container")
        ADD_OBJECT_NOT_NIL([o layoutManager], @"Layout manager")
        ADD_NUMBER([o lineFragmentPadding], @"Line fragment padding")
        ADD_OBJECT_NOT_NIL([o textView], @"Text view")
        ADD_BOOL([o widthTracksTextView], @"Width tracks text view")
}

- (void)addNSTextList:(id)object
{
        NSTextList* o = object;
        ADD_CLASS_LABEL(@"NSTextList Info");
        ADD_ENUM(TextListOptions, [o listOptions], @"List options")
        ADD_OBJECT([o markerFormat], @"Marker format")
}

- (void)addNSTextTab:(id)object
{
        NSTextTab* o = object;
        ADD_CLASS_LABEL(@"NSTextTab Info");
        ADD_ENUM(TextAlignment, [o alignment], @"Alignment")
        ADD_NUMBER([o location], @"Location")
        ADD_OBJECT([o options], @"Options")
        ADD_ENUM(TextTabType, [o tabStopType], @"Tab stop type")
}

- (void)addNSToolbar:(id)object
{
        NSToolbar* o = object;
        ADD_CLASS_LABEL(@"NSToolbar Info");
        ADD_BOOL([o allowsUserCustomization], @"Allows user customization")
        ADD_BOOL([o autosavesConfiguration], @"Autosaves configuration")
        ADD_DICTIONARY([o configurationDictionary], @"Configuration dictionary")
        ADD_BOOL([o customizationPaletteIsRunning], @"Customization palette is running")
        ADD_OBJECT([o delegate], @"Delegate")
        ADD_ENUM(ToolbarDisplayMode, [o displayMode], @"Display mode")
        ADD_OBJECT([(NSToolbar*)o identifier], @"Identifier")
        ADD_BOOL([o isVisible], @"Is visible")
        ADD_OBJECTS([o items], @"Items")
        ADD_OBJECT_NOT_NIL([o selectedItemIdentifier], @"Selected item identifier")
        ADD_BOOL([o showsBaselineSeparator], @"Shows baseline separator")
        ADD_ENUM(ToolbarSizeMode, [o sizeMode], @"Identifier")
        ADD_OBJECTS([o visibleItems], @"Visible items")
}

- (void)addNSToolbarItem:(id)object
{
        if ([object isKindOfClass:[NSToolbarItemGroup class]]) {
                NSToolbarItemGroup* o = object;
                ADD_CLASS_LABEL(@"NSToolbarItemGroup Info");
                ADD_OBJECTS([o subitems], @"Subitems")
        }

        NSToolbarItem* o = object;
        ADD_CLASS_LABEL(@"NSToolbarItem Info");
        ADD_SEL([o action], @"Action")
        ADD_BOOL([o allowsDuplicatesInToolbar], @"Allows duplicates in toolbar")
        ADD_BOOL([o autovalidates], @"Autovalidates")
        ADD_OBJECT([o image], @"Image")
        ADD_BOOL([o isEnabled], @"Is enabled")
        ADD_OBJECT([(NSToolbarItem*)o itemIdentifier], @"Item identifier")
        ADD_OBJECT([o label], @"Label")
        ADD_SIZE([o maxSize], @"Max size")
        ADD_OBJECT_NOT_NIL([o menuFormRepresentation], @"Menu form representation")
        ADD_SIZE([o minSize], @"Min size")
        ADD_OBJECT([o paletteLabel], @"Palette label")
        ADD_NUMBER([o tag], @"Tag")
        ADD_OBJECT([o target], @"Target")
        ADD_OBJECT([o toolbar], @"Toolbar")
        ADD_OBJECT_NOT_NIL([o toolTip], @"Tool tip")
        ADD_OBJECT([o view], @"View")
        ADD_ENUM(ToolbarItemVisibilityPriority, [o visibilityPriority], @"Visibility priority")
}

- (void)addNSTrackingArea:(id)object
{
        NSTrackingArea* o = object;
        ADD_CLASS_LABEL(@"NSTrackingArea Info");
        ADD_ENUM(TrackingAreaOptions, [o options], @"Options")
        ADD_OBJECT([o owner], @"Owner")
        ADD_RECT([o rect], @"Rect")
        ADD_DICTIONARY([o userInfo], @"User info")
}

- (void)addNSUndoManager:(id)object
{
        NSUndoManager* o = object;
        ADD_CLASS_LABEL(@"NSUndoManager Info");
        ADD_NUMBER([o groupingLevel], @"Grouping level")
        ADD_BOOL([o groupsByEvent], @"Groups by event")
        ADD_BOOL([o isUndoRegistrationEnabled], @"Is undo registration enabled")
        ADD_NUMBER([o levelsOfUndo], @"Levels of undo")
        ADD_OBJECT_NOT_NIL([o redoActionName], @"Redo action name")
        ADD_OBJECT_NOT_NIL([o redoMenuItemTitle], @"Redo menu item title")
        ADD_OBJECTS([o runLoopModes], @"Run loop modes")
        ADD_OBJECT_NOT_NIL([o undoActionName], @"Undo action name")
        ADD_OBJECT_NOT_NIL([o undoMenuItemTitle], @"Undo menu item title")
}

- (void)addNSATSTypesetter:(id)object
{
        if ([object isKindOfClass:NSClassFromString(@"NSATSTypesetter")]) {
                //  NSATSTypesetter *o = object;
                //  ADD_CLASS_LABEL(@"NSATSTypesetter Info");
        }

        NSTypesetter* o = object;
        ADD_CLASS_LABEL(@"NSTypesetter Info");
        //ADD_OBJECT(            [o attributedString]                   ,@"Attributed string")
        ADD_DICTIONARY([o attributesForExtraLineFragment], @"Attributes for extra line fragment")
        ADD_BOOL([o bidiProcessingEnabled], @"Bidi processing enabled")
        ADD_OBJECT_NOT_NIL([o currentTextContainer], @"Current text container")
        ADD_NUMBER([o hyphenationFactor], @"Hyphenation factor")
        ADD_OBJECT_NOT_NIL([o layoutManager], @"Layout manager")
        ADD_NUMBER([o lineFragmentPadding], @"Line fragment padding")
        ADD_ENUM(TypesetterBehavior, [o typesetterBehavior], @"Typesetter behavior")
        ADD_BOOL([o usesFontLeading], @"Uses font leading")
}

- (void)processNSView:(id)object
{

        if ([object isKindOfClass:[NSBox class]]) {
                NSBox* o = object;
                ADD_CLASS_LABEL(@"NSBox Info");
                ADD_OBJECT([o borderColor], @"Border color")
                ADD_RECT([o borderRect], @"Border rect")
                ADD_ENUM(BorderType, [o borderType], @"Border type")
                ADD_NUMBER([o borderWidth], @"Border width")
                ADD_ENUM(BoxType, [o boxType], @"Box type")
                ADD_OBJECT([o contentView], @"Content view")
                ADD_SIZE([o contentViewMargins], @"Content view margins")
                ADD_NUMBER([o cornerRadius], @"Corner radius")
                ADD_OBJECT([o fillColor], @"Fill color")
                ADD_BOOL([o isTransparent], @"Is transparent")
                ADD_OBJECT([o title], @"Title")
                ADD_OBJECT([o titleCell], @"Title cell")
                ADD_OBJECT([o titleFont], @"Title font")
                ADD_ENUM(TitlePosition, [o titlePosition], @"Title position")
                ADD_RECT([o titleRect], @"Title rect")
        }
        if ([object isKindOfClass:[NSCollectionView class]]) {
                NSCollectionView* o = object;
                ADD_CLASS_LABEL(@"NSCollectionView Info");
                ADD_BOOL([o allowsMultipleSelection], @"Allows multiple selection")
                ADD_OBJECTS([o backgroundColors], @"Background colors")
                ADD_OBJECT([o content], @"Content")
                ADD_BOOL([o isFirstResponder], @"Is first responder")
                ADD_BOOL([o isSelectable], @"Is selectable")
                ADD_OBJECT_NOT_NIL([o itemPrototype], @"Item prototype")
                ADD_SIZE([o maxItemSize], @"Max item size")
                ADD_NUMBER([o maxNumberOfColumns], @"Max number of columns")
                ADD_NUMBER([o maxNumberOfRows], @"Max number of rows")
                ADD_SIZE([o minItemSize], @"Min item size")
                ADD_OBJECT_NOT_NIL([o selectionIndexes], @"Selection indexes")
        }
        else if ([object isKindOfClass:[NSControl class]]) {
                [self processNSControl:object];
        }
        else if ([object isKindOfClass:[NSClipView class]]) {
                NSClipView* o = object;
                ADD_CLASS_LABEL(@"NSClipView Info");
                ADD_OBJECT([o backgroundColor], @"Background color")
                ADD_BOOL([o copiesOnScroll], @"Copies on scroll")
                ADD_OBJECT([o documentCursor], @"Document cursor")
                ADD_RECT([o documentRect], @"Document rect")
                ADD_OBJECT([o documentView], @"Document view")
                ADD_RECT([o documentVisibleRect], @"Document visible rect")
                ADD_BOOL([o drawsBackground], @"Draws background")
        }
        else if ([object isKindOfClass:[NSOpenGLView class]]) {
                NSOpenGLView* o = object;
                ADD_CLASS_LABEL(@"NSOpenGLView Info");
                ADD_OBJECT([o openGLContext], @"OpenGL context")
                ADD_OBJECT([o pixelFormat], @"Pixel format")
        }
        else if ([object isKindOfClass:[NSProgressIndicator class]]) {
                NSProgressIndicator* o = object;
                ADD_CLASS_LABEL(@"NSProgressIndicator Info");
                ADD_ENUM(ControlSize, [o controlSize], @"Control size")
                ADD_ENUM(ControlTint, [o controlTint], @"Control tint")
                if ([o style] == NSProgressIndicatorBarStyle && ![o isIndeterminate])
                        ADD_NUMBER([o doubleValue], @"Double value")
                ADD_BOOL([o isBezeled], @"Is bezeled")
                ADD_BOOL([o isDisplayedWhenStopped], @"Is displayed when stopped")
                if ([o style] == NSProgressIndicatorBarStyle && ![o isIndeterminate]) {
                        ADD_NUMBER([o maxValue], @"Max value")
                        ADD_NUMBER([o minValue], @"Min value")
                }
                ADD_ENUM(ProgressIndicatorStyle, [o style], @"Style")
                ADD_BOOL([o usesThreadedAnimation], @"Uses threaded animation")
        }
        else if ([object isKindOfClass:[NSRulerView class]]) {
                NSRulerView* o = object;
                ADD_CLASS_LABEL(@"NSRulerView Info");
                ADD_OBJECT_NOT_NIL([o accessoryView], @"Accessory view")
                ADD_NUMBER([o baselineLocation], @"Baseline location")
                ADD_OBJECT([o clientView], @"Client view")
                ADD_BOOL([o isFlipped], @"Is flipped")
                ADD_OBJECTS([o markers], @"Markers")
                ADD_OBJECT([o measurementUnits], @"Measurement units")
                ADD_ENUM(RulerOrientation, [o orientation], @"Orientation")
                ADD_NUMBER([o originOffset], @"Origin offset")
                ADD_NUMBER([o requiredThickness], @"Required thickness")
                ADD_NUMBER([o reservedThicknessForAccessoryView], @"Reserved thickness for accessory view")
                ADD_NUMBER([o reservedThicknessForMarkers], @"Reserved thickness for markers")
                ADD_NUMBER([o ruleThickness], @"Rule thickness")
                ADD_OBJECT([o scrollView], @"ScrollView")
        }
        else if ([object isKindOfClass:[NSScrollView class]]) {
                NSScrollView* o = object;
                ADD_CLASS_LABEL(@"NSScrollView Info");
                ADD_BOOL([o autohidesScrollers], @"Autohides scrollers")
                ADD_OBJECT([o backgroundColor], @"Background color")
                ADD_ENUM(BorderType, [o borderType], @"Border type")
                ADD_SIZE([o contentSize], @"Content size")
                ADD_OBJECT([o contentView], @"Content view")
                ADD_OBJECT([o documentCursor], @"Document cursor")
                ADD_OBJECT([o documentView], @"Document view")
                ADD_RECT([o documentVisibleRect], @"Document visible rect")
                ADD_BOOL([o drawsBackground], @"Draws background")
                ADD_BOOL([o hasHorizontalRuler], @"Has horizontal ruler")
                ADD_BOOL([o hasHorizontalScroller], @"Has horizontal scroller")
                ADD_BOOL([o hasVerticalRuler], @"Has vertical ruler")
                ADD_BOOL([o hasVerticalScroller], @"Has vertical scroller")
                ADD_NUMBER([o horizontalLineScroll], @"Horizontal line scroll")
                ADD_NUMBER([o horizontalPageScroll], @"Horizontal page scroll")
                ADD_OBJECT([o horizontalRulerView], @"Horizontal ruler view")
                ADD_OBJECT([o horizontalScroller], @"Horizontal scroller")
                ADD_NUMBER([o lineScroll], @"Line scroll")
                ADD_NUMBER([o pageScroll], @"Page scroll")
                ADD_BOOL([o rulersVisible], @"Ruller visible")
                ADD_BOOL([o scrollsDynamically], @"Scrolls dynamically")
                ADD_NUMBER([o verticalLineScroll], @"Vertical line scroll")
                ADD_NUMBER([o verticalPageScroll], @"Vertical page scroll")
                ADD_OBJECT([o verticalRulerView], @"Vertical ruler view")
                ADD_OBJECT([o verticalScroller], @"Vertical scroller")
        }
        else if ([object isKindOfClass:[NSSplitView class]]) {
                NSSplitView* o = object;
                ADD_CLASS_LABEL(@"NSSplitView Info");
                ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                ADD_NUMBER([o dividerThickness], @"Divider thickness")
                ADD_BOOL([o isVertical], @"Is vertical")
                ADD_OBJECT_NOT_NIL([o autosaveName], @"Autosave name")
        }
        else if ([object isKindOfClass:[NSTabView class]]) {
                NSTabView* o = object;
                ADD_CLASS_LABEL(@"NSTabView Info");
                ADD_BOOL([o allowsTruncatedLabels], @"Allows truncated labels")
                ADD_RECT([o contentRect], @"Content rect")
                ADD_ENUM(ControlSize, [o controlSize], @"Control size")
                ADD_ENUM(ControlTint, [o controlTint], @"Control tint")
                ADD_OBJECT([o delegate], @"Delegate")
                ADD_BOOL([o drawsBackground], @"Draws background")
                ADD_OBJECT([o font], @"Font")
                ADD_SIZE([o minimumSize], @"Minimum size")
                ADD_OBJECT([o selectedTabViewItem], @"Selected tab view item")
                ADD_OBJECTS([o tabViewItems], @"Tab view items")
                ADD_ENUM(TabViewType, [o tabViewType], @"Tab view type")
        }
        else if ([object isKindOfClass:[NSTableHeaderView class]]) {
                NSTableHeaderView* o = object;
                ADD_CLASS_LABEL(@"NSTableHeaderView Info");
                ADD_OBJECT([o tableView], @"Table view")
        }
        else if ([object isKindOfClass:[NSText class]]) {
                if ([object isKindOfClass:[NSTextView class]]) {
                        NSTextView* o = object;
                        ADD_CLASS_LABEL(@"NSTextView Info");
                        ADD_OBJECTS([o acceptableDragTypes], @"Acceptable drag types")
                        ADD_BOOL([o acceptsGlyphInfo], @"Accepts glyph info")
                        ADD_OBJECTS([o allowedInputSourceLocales], @"Allowed input source locales")
                        ADD_BOOL([o allowsImageEditing], @"Allows image editing")
                        ADD_BOOL([o allowsDocumentBackgroundColorChange], @"Allows document background color change")
                        ADD_BOOL([o allowsUndo], @"Allows undo")
                        ADD_OBJECT_NOT_NIL([o defaultParagraphStyle], @"Default paragraph style")
                        ADD_BOOL([o displaysLinkToolTips], @"Displays link tool tips")
                        ADD_OBJECT([o insertionPointColor], @"Insertion point color")
                        ADD_BOOL([o isAutomaticLinkDetectionEnabled], @"Is automatic link detection enabled")
                        ADD_BOOL([o isAutomaticQuoteSubstitutionEnabled], @"Is automatic quote substitution enabled")
                        ADD_BOOL([o isContinuousSpellCheckingEnabled], @"Is continuous spell checking enabled")
                        ADD_BOOL([o isGrammarCheckingEnabled], @"Is grammar checking enabled")
                        ADD_OBJECT_NOT_NIL([o layoutManager], @"Layout manager")
                        ADD_DICTIONARY([o linkTextAttributes], @"Link text attributes")
                        ADD_DICTIONARY([o markedTextAttributes], @"Marked text attributes")
                        ADD_RANGE([o rangeForUserCompletion], @"Range for user completion")
                        ADD_OBJECTS([o rangesForUserCharacterAttributeChange], @"Ranges for user character attribute change")
                        ADD_OBJECTS([o rangesForUserParagraphAttributeChange], @"Ranges for user paragraph attribute change")
                        ADD_OBJECTS([o rangesForUserTextChange], @"Ranges for user text change")
                        ADD_OBJECTS([o readablePasteboardTypes], @"Readable pasteboard types")
                        ADD_OBJECTS([o selectedRanges], @"Selected ranges")
                        ADD_DICTIONARY([o selectedTextAttributes], @"Selected text attributes")
                        ADD_ENUM(SelectionAffinity, [o selectionAffinity], @"Selection affinity")
                        ADD_ENUM(SelectionGranularity, [o selectionGranularity], @"Selection granularity")
                        ADD_BOOL([o shouldDrawInsertionPoint], @"Should draw insertion point")
                        ADD_BOOL([o smartInsertDeleteEnabled], @"Smart insert delete enabled")
                        ADD_NUMBER([o spellCheckerDocumentTag], @"Spell checker document tag")
                        ADD_OBJECT([o textContainer], @"Text container")
                        ADD_SIZE([o textContainerInset], @"Text container inset")
                        ADD_POINT([o textContainerOrigin], @"Text container origin")
                        ADD_OBJECT([o textStorage], @"Text storage")
                        ADD_DICTIONARY([o typingAttributes], @"Typing attributes")
                        ADD_BOOL([o usesFindPanel], @"Uses find panel")
                        ADD_BOOL([o usesFontPanel], @"Uses font panel")
                        ADD_BOOL([o usesRuler], @"Uses ruler")
                        ADD_OBJECT([o writablePasteboardTypes], @"Writable pasteboard types")
                }

                NSText* o = object;
                ADD_CLASS_LABEL(@"NSText Info");
                ADD_ENUM(TextAlignment, [o alignment], @"Alignment")
                ADD_OBJECT([o backgroundColor], @"Background color")
                ADD_ENUM(WritingDirection, [o baseWritingDirection], @"Base writing direction")
                ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                ADD_BOOL([o drawsBackground], @"Draws background")
                ADD_OBJECT([o font], @"Font")
                ADD_BOOL([o importsGraphics], @"Imports graphics")
                ADD_BOOL([o isEditable], @"Is editable")
                ADD_BOOL([o isFieldEditor], @"Is field editor")
                ADD_BOOL([o isHorizontallyResizable], @"Is horizontally resizable")
                ADD_BOOL([o isRichText], @"Is rich text")
                ADD_BOOL([o isRulerVisible], @"Is ruler visible")
                ADD_BOOL([o isSelectable], @"Is selectable")
                ADD_BOOL([o isVerticallyResizable], @"Is vertically resizable")
                ADD_SIZE([o maxSize], @"Max size")
                ADD_SIZE([o minSize], @"Min size")
                ADD_RANGE([o selectedRange], @"Selected range")
                ADD_OBJECT([o string], @"String")
                ADD_OBJECT_NOT_NIL([o textColor], @"Text color")
                ADD_BOOL([o usesFontPanel], @"Uses font panel")
        }

        NSView* o = object;
        ADD_CLASS_LABEL(@"NSView Info");
        ADD_ENUM(AutoresizingMaskOptions, [o autoresizingMask], @"Autoresizing mask")
        ADD_BOOL([o autoresizesSubviews], @"Autoresizes subviews")
        ADD_RECT([o bounds], @"Bounds")
        ADD_NUMBER([o boundsRotation], @"Bounds rotation")
        ADD_BOOL([o canBecomeKeyView], @"Can become key view")
        ADD_BOOL([o canDraw], @"Can draw")
        ADD_OBJECT_NOT_NIL([o enclosingMenuItem], @"Enclosing menu item")
        ADD_OBJECT_NOT_NIL([o enclosingScrollView], @"Enclosing scroll view")
        ADD_RECT([o frame], @"Frame")
        ADD_NUMBER([o frameRotation], @"Frame rotation")
        ADD_ENUM(FocusRingType, [o focusRingType], @"Focus ring type")
        ADD_NUMBER([o gState], @"gState")
        ADD_NUMBER([o heightAdjustLimit], @"Height adjust limit")
        ADD_BOOL([o isFlipped], @"Is flipped")
        ADD_BOOL([o isHidden], @"Is hidden")
        ADD_BOOL([o isHiddenOrHasHiddenAncestor], @"Is hidden or has hidden ancestor")
        ADD_BOOL([o isInFullScreenMode], @"Is in full screen mode")
        ADD_BOOL([o isOpaque], @"Is opaque")
        ADD_BOOL([o isRotatedFromBase], @"Is rotated from base")
        ADD_BOOL([o isRotatedOrScaledFromBase], @"Is rotated or scaled from base")
        ADD_OBJECT([o layer], @"Layer")
        ADD_BOOL([o mouseDownCanMoveWindow], @"Mouse down can move window")
        ADD_BOOL([o needsDisplay], @"Needs display")
        ADD_BOOL([o needsPanelToBecomeKey], @"Needs panel to become key")
        ADD_OBJECT([o nextKeyView], @"Next key view")
        ADD_OBJECT([o nextValidKeyView], @"Next valid key view")
        ADD_OBJECT([o opaqueAncestor], @"Opaque ancestor")
        ADD_BOOL([o preservesContentDuringLiveResize], @"Preserves content during live resize")
        ADD_BOOL([o postsBoundsChangedNotifications], @"Posts bounds changed notifications")
        ADD_BOOL([o postsFrameChangedNotifications], @"Posts frame changed notifications")
        ADD_OBJECT([o previousKeyView], @"Previous key view")
        ADD_OBJECT([o previousValidKeyView], @"Previous valid key view")
        ADD_OBJECT([o printJobTitle], @"Print job title")
        ADD_OBJECTS([o registeredDraggedTypes], @"Registered dragged types")
        ADD_BOOL([o shouldDrawColor], @"Should draw color")
        ADD_NUMBER([o tag], @"Tag")
        ADD_OBJECTS([o trackingAreas], @"Tracking areas")
        ADD_RECT([o visibleRect], @"Visible rect")
        ADD_BOOL([o wantsDefaultClipping], @"Wants default clipping")
        ADD_BOOL([o wantsLayer], @"Wants layer")
        ADD_NUMBER([o widthAdjustLimit], @"Width adjust limit")
        ADD_OBJECT([o window], @"Window")
}

- (void)processNSControl:(id)object
{
        {
                if ([object isKindOfClass:[NSBrowser class]]) {
                        NSBrowser* o = object;
                        ADD_CLASS_LABEL(@"NSBrowser Info");
                        ADD_BOOL([o allowsBranchSelection], @"Allows branch selection")
                        ADD_BOOL([o allowsEmptySelection], @"Allows empty selection")
                        ADD_BOOL([o allowsMultipleSelection], @"Allows multiple selection")
                        ADD_BOOL([o allowsTypeSelect], @"Allows type select")
                        ADD_OBJECT([o backgroundColor], @"Background color")
                        ADD_OBJECT([o cellPrototype], @"Cell prototype")
                        ADD_ENUM(BrowserColumnResizingType, [o columnResizingType], @"Column resizing type")
                        ADD_OBJECT([o columnsAutosaveName], @"Columns autosave name")
                        ADD_OBJECT([o delegate], @"Delegate")
                        ADD_SEL([o doubleAction], @"Double action")
                        ADD_NUMBER([o firstVisibleColumn], @"First visible column")
                        ADD_BOOL([o hasHorizontalScroller], @"Has horizontal scroller")
                        ADD_BOOL([o isLoaded], @"Is loaded")
                        ADD_BOOL([o isTitled], @"Is titled")
                        ADD_NUMBER([o lastColumn], @"Last column")
                        ADD_NUMBER([o lastVisibleColumn], @"Last visible column")
                        ADD_OBJECT([o matrixClass], @"Matrix class")
                        ADD_NUMBER([o maxVisibleColumns], @"Max visible columns")
                        ADD_NUMBER([o minColumnWidth], @"Min column width")
                        ADD_NUMBER([o numberOfVisibleColumns], @"Number of visible columns")
                        ADD_OBJECT([o path], @"Path")
                        ADD_OBJECT([o pathSeparator], @"Path separator")
                        ADD_BOOL([o prefersAllColumnUserResizing], @"Prefers all column user resizing")
                        ADD_BOOL([o reusesColumns], @"Reuses columns")
                        ADD_OBJECTS([o selectedCells], @"Selected cells")
                        ADD_NUMBER([o selectedColumn], @"Selected column")
                        ADD_BOOL([o sendsActionOnArrowKeys], @"Sends action on arrow keys")
                        ADD_BOOL([o separatesColumns], @"Separates columns")
                        ADD_BOOL([o takesTitleFromPreviousColumn], @"Takes title from previous column")
                        ADD_NUMBER([o titleHeight], @"Title height")
                }
                else if ([object isKindOfClass:[NSButton class]]) {
                        if ([object isKindOfClass:[NSPopUpButton class]]) {
                                NSPopUpButton* o = object;
                                ADD_CLASS_LABEL(@"NSPopUpButton Info");
                                ADD_BOOL([o autoenablesItems], @"Autoenables Items")
                                ADD_NUMBER([o indexOfSelectedItem], @"Index of selected item")
                                ADD_OBJECTS([o itemArray], @"Item array")
                                ADD_NUMBER([o numberOfItems], @"Number of items")
                                ADD_OBJECT([o objectValue], @"Object value")
                                ADD_ENUM(RectEdge, [o preferredEdge], @"Preferred edge")
                                ADD_BOOL([o pullsDown], @"Pulls down")
                                ADD_OBJECT([o selectedItem], @"Selected item")
                        }

                        NSButton* o = object;
                        ADD_CLASS_LABEL(@"NSButton Info");
                        ADD_BOOL([o allowsMixedState], @"Allows mixed state")
                        ADD_OBJECT_NOT_NIL([o alternateImage], @"Alternate image")
                        ADD_OBJECT([o alternateTitle], @"Alternate title")
                        ADD_OBJECT([o attributedAlternateTitle], @"Attributed alternate title")
                        ADD_OBJECT([o attributedTitle], @"Attributed title")
                        ADD_ENUM(BezelStyle, [o bezelStyle], @"Bezel style")
                        ADD_OBJECT([o image], @"Image")
                        ADD_ENUM(CellImagePosition, [o imagePosition], @"Image position")
                        ADD_BOOL([o isBordered], @"Is bordered")
                        ADD_BOOL([o isTransparent], @"Is transparent")
                        ADD_OBJECT([o keyEquivalent], @"Key equivalent")
                        ADD_ENUM(KeyModifierMask, [o keyEquivalentModifierMask], @"Key equivalent modifier mask")
                        ADD_BOOL([o showsBorderOnlyWhileMouseInside], @"Shows border only while mouse inside")
                        ADD_OBJECT_NOT_NIL([o sound], @"Sound")
                        ADD_ENUM(CellStateValue, [o state], @"State")
                        ADD_OBJECT([o title], @"Title")
                }
                else if ([object isKindOfClass:[NSColorWell class]]) {
                        NSColorWell* o = object;
                        ADD_CLASS_LABEL(@"NSColorWell Info");
                        ADD_OBJECT([o color], @"Color")
                        ADD_BOOL([o isActive], @"Is active")
                        ADD_BOOL([o isBordered], @"Is bordered")
                }
                else if ([object isKindOfClass:[NSDatePicker class]]) {
                        NSDatePicker* o = object;
                        ADD_CLASS_LABEL(@"NSDatePicker Info");
                        ADD_OBJECT([o backgroundColor], @"Background color")
                        ADD_OBJECT([o calendar], @"Calendar")
                        ADD_ENUM(DatePickerElementFlags, [o datePickerElements], @"Date picker elements")
                        ADD_ENUM(DatePickerMode, [o datePickerMode], @"Date picker mode")
                        ADD_ENUM(DatePickerStyle, [o datePickerStyle], @"Date picker style")
                        ADD_OBJECT([o dateValue], @"Date value")
                        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                        ADD_BOOL([o drawsBackground], @"Draws background")
                        ADD_BOOL([o isBezeled], @"Is bezeled")
                        ADD_BOOL([o isBordered], @"Is bordered")
                        ADD_OBJECT_NOT_NIL([o locale], @"Locale")
                        ADD_OBJECT([o maxDate], @"Max date")
                        ADD_OBJECT([o minDate], @"Min date")
                        ADD_OBJECT([o textColor], @"Text Color")
                        ADD_NUMBER([o timeInterval], @"Time interval")
                        ADD_OBJECT([o timeZone], @"Time zone")
                }
                else if ([object isKindOfClass:[NSImageView class]]) {
                        NSImageView* o = object;
                        ADD_CLASS_LABEL(@"NSImageView Info");
                        ADD_BOOL([o allowsCutCopyPaste], @"Allows cut copy paste")
                        ADD_BOOL([o animates], @"Animates")
                        ADD_OBJECT([o image], @"Image")
                        ADD_ENUM(ImageAlignment, [o imageAlignment], @"Image alignment")
                        ADD_ENUM(ImageFrameStyle, [o imageFrameStyle], @"Image frame style")
                        ADD_ENUM(ImageScaling, [o imageScaling], @"Image scaling")
                        ADD_BOOL([o isEditable], @"Is editable")
                }
                else if ([object isKindOfClass:[NSLevelIndicator class]]) {
                        NSLevelIndicator* o = object;
                        ADD_CLASS_LABEL(@"NSLevelIndicator Info");
                        ADD_NUMBER([o criticalValue], @"Critical value")
                        ADD_NUMBER([o maxValue], @"Max value")
                        ADD_NUMBER([o minValue], @"Min value")
                        ADD_NUMBER([o numberOfMajorTickMarks], @"Number of major tick marks")
                        ADD_NUMBER([o numberOfTickMarks], @"Number of tick marks")
                        ADD_OBJECT(objectFromTickMarkPosition([o tickMarkPosition], NO), @"Tick mark position")
                        ADD_NUMBER([o warningValue], @"Warning value")
                }
                else if ([object isKindOfClass:[NSMatrix class]]) {
                        NSMatrix* o = object;
                        ADD_CLASS_LABEL(@"NSMatrix Info");
                        ADD_BOOL([o allowsEmptySelection], @"Allows empty selection")
                        ADD_BOOL([o autosizesCells], @"Autosizes cells")
                        ADD_OBJECT([o backgroundColor], @"Background color")
                        ADD_OBJECT([o cellBackgroundColor], @"Cell background color")
                        ADD_OBJECT([o cellClass], @"Cell class")
                        ADD_SIZE([o cellSize], @"Cell size");

                        NSInteger numberOfColumns = [o numberOfColumns];
                        NSInteger numberOfRows = [o numberOfRows];

                        if (numberOfRows != 0) {
                                for (NSInteger column = 0; column < numberOfColumns; column++) {
                                        NSMutableArray* columnArray = [NSMutableArray arrayWithCapacity:numberOfRows];
                                        for (NSInteger row = 0; row < numberOfRows; row++)
                                                [columnArray addObject:[o cellAtRow:row column:column]];
                                        ADD_OBJECT([NSArray arrayWithArray:columnArray], ([NSString stringWithFormat:@"Column %ld", (long)column]))
                                }
                        }

                        ADD_OBJECT([o delegate], @"Delegate")
                        ADD_SEL([o doubleAction], @"Double action")
                        ADD_BOOL([o drawsBackground], @"Draws background")
                        ADD_BOOL([o drawsCellBackground], @"Draws cell background")
                        ADD_SIZE([o intercellSpacing], @"Intercell spacing")
                        ADD_BOOL([o isAutoscroll], @"Is autoscroll")
                        ADD_BOOL([o isSelectionByRect], @"Is selection by rect")
                        ADD_OBJECT([o keyCell], @"Key cell")
                        ADD_ENUM(MatrixMode, [(NSMatrix*)o mode], @"Mode")
                        ADD_NUMBER([o numberOfColumns], @"Number of columns")
                        ADD_NUMBER([o numberOfRows], @"Number of rows")
                        ADD_OBJECT([o prototype], @"Prototype")
                        ADD_OBJECTS([o selectedCells], @"Selected cells")
                        ADD_NUMBER([o selectedColumn], @"Selected column")
                        ADD_NUMBER([o selectedRow], @"Selected row")
                        ADD_BOOL([o tabKeyTraversesCells], @"Tab key traverses cells")
                }
                else if ([object isKindOfClass:[NSPathControl class]]) {
                        NSPathControl* o = object;
                        ADD_CLASS_LABEL(@"NSPathControl Info");
                        ADD_OBJECT_NOT_NIL([o backgroundColor], @"Background color")
                        ADD_OBJECT([o delegate], @"Delegate")
                        ADD_SEL([o doubleAction], @"Double action")
                        ADD_OBJECTS([o pathComponentCells], @"Path component cells")
                        ADD_ENUM(PathStyle, [o pathStyle], @"Path style")
                        ADD_OBJECT([o URL], @"URL")
                }
                else if ([object isKindOfClass:[NSRuleEditor class]]) {
                        if ([object isKindOfClass:[NSPredicateEditor class]]) {
                                NSPredicateEditor* o = object;
                                ADD_CLASS_LABEL(@"NSPredicateEditor Info");
                                ADD_OBJECTS([o rowTemplates], @"Row templates")
                        }

                        NSRuleEditor* o = object;
                        ADD_CLASS_LABEL(@"NSRuleEditor Info");
                        ADD_BOOL([o canRemoveAllRows], @"Can remove all rows")
                        ADD_OBJECT_NOT_NIL([o criteriaKeyPath], @"Criteria key path")
                        ADD_OBJECT([o delegate], @"Delegate")
                        ADD_OBJECT_NOT_NIL([o displayValuesKeyPath], @"Display values key path")
                        ADD_DICTIONARY([o formattingDictionary], @"Formatting dictionary")
                        ADD_OBJECT_NOT_NIL([o formattingStringsFilename], @"Formatting strings filename")
                        ADD_BOOL([o isEditable], @"Is editable")
                        ADD_ENUM(RuleEditorNestingMode, [o nestingMode], @"Nesting mode")
                        ADD_NUMBER([o numberOfRows], @"Number of rows")
                        ADD_OBJECT([o predicate], @"Predicate")
                        ADD_OBJECT([o rowClass], @"Row class")
                        ADD_NUMBER([o rowHeight], @"Row height")
                        ADD_OBJECT_NOT_NIL([o rowTypeKeyPath], @"Row type key path")
                        ADD_OBJECT_NOT_NIL([o selectedRowIndexes], @"Selected row indexes")
                        ADD_OBJECT_NOT_NIL([o subrowsKeyPath], @"Subrows key path")
                }
                else if ([object isKindOfClass:[NSScroller class]]) {
                        NSScroller* o = object;
                        ADD_CLASS_LABEL(@"NSScroller Info");
                        ADD_ENUM(ScrollArrowPosition, [o arrowsPosition], @"Arrows position")
                        ADD_ENUM(ControlSize, [o controlSize], @"Control size")
                        ADD_ENUM(ControlTint, [o controlTint], @"Control tint")
                        ADD_NUMBER([o doubleValue], @"Double value")
                        ADD_ENUM(ScrollerPart, [o hitPart], @"Hit part")
                        ADD_NUMBER([o knobProportion], @"Knob proportion")
                        ADD_ENUM(UsableScrollerParts, [o usableParts], @"Usable parts")
                }
                else if ([object isKindOfClass:[NSSegmentedControl class]]) {
                        NSSegmentedControl* o = object;
                        NSInteger segmentCount = [o segmentCount];
                        ADD_CLASS_LABEL(@"NSSegmentedControl Info");

                        ADD_NUMBER(segmentCount, @"Segment count")
                        ADD_NUMBER([o selectedSegment], @"Selected segment")

                        for (NSInteger i = 0; i < segmentCount; i++) {
                                ADD_OBJECT_NOT_NIL([o imageForSegment:i], ([NSString stringWithFormat:@"Image for segment %ld", (long)i]))
                                ADD_BOOL([o isEnabledForSegment:i], ([NSString stringWithFormat:@"Is enabled for segment %ld", (long)i]))
                                ADD_BOOL([o isSelectedForSegment:i], ([NSString stringWithFormat:@"Is selected for segment %ld", (long)i]))
                                ADD_OBJECT_NOT_NIL([o labelForSegment:i], ([NSString stringWithFormat:@"Label for segment %ld", (long)i]))
                                ADD_OBJECT_NOT_NIL([o menuForSegment:i], ([NSString stringWithFormat:@"Menu for segment %ld", (long)i]))
                                if ([o widthForSegment:i] != 0)
                                        ADD_NUMBER([o widthForSegment:i], ([NSString stringWithFormat:@"Width for segment %ld", (long)i]))
                        }
                }
                else if ([object isKindOfClass:[NSSlider class]]) {
                        NSSlider* o = object;
                        ADD_CLASS_LABEL(@"NSSlider Info");
                        ADD_BOOL([o allowsTickMarkValuesOnly], @"Allows tick mark values only")
                        ADD_NUMBER([o altIncrementValue], @"Alt increment value")
                        ADD_NUMBER([(NSSlider*)o isVertical], @"Is vertical")
                        ADD_NUMBER([o knobThickness], @"Knob thickness")
                        ADD_NUMBER([o maxValue], @"Max value")
                        ADD_NUMBER([o minValue], @"Min value")
                        ADD_NUMBER([o numberOfTickMarks], @"Number of tick marks")
                        ADD_OBJECT(objectFromTickMarkPosition([o tickMarkPosition], [(NSSlider*)o isVertical] == 1), @"Tick mark position")
                        ADD_OBJECT([o title], @"title")
                }
                else if ([object isKindOfClass:[NSTableView class]]) {
                        if ([object isKindOfClass:[NSOutlineView class]]) {
                                NSOutlineView* o = object;
                                ADD_CLASS_LABEL(@"NSOutlineView Info");
                                ADD_BOOL([o autoresizesOutlineColumn], @"Autoresizes outline column")
                                ADD_BOOL([o autosaveExpandedItems], @"Autosave expanded items")
                                ADD_BOOL([o indentationMarkerFollowsCell], @"Indentation marker follows cell")
                                ADD_NUMBER([o indentationPerLevel], @"Indentation per level")
                                ADD_OBJECT([o outlineTableColumn], @"Outline table column")
                        }

                        NSTableView* o = object;
                        ADD_CLASS_LABEL(@"NSTableView Info");
                        ADD_BOOL([o allowsColumnReordering], @"Allows column reordering")
                        ADD_BOOL([o allowsColumnResizing], @"Allows column resizing")
                        ADD_BOOL([o allowsColumnSelection], @"Allows column selection")
                        ADD_BOOL([o allowsEmptySelection], @"Allows empty selection")
                        ADD_BOOL([o allowsMultipleSelection], @"Allows multiple selection")
                        ADD_BOOL([o allowsTypeSelect], @"Allows type select")
                        ADD_OBJECT_NOT_NIL([o autosaveName], @"Autosave name")
                        ADD_BOOL([o autosaveTableColumns], @"Autosave table columns")
                        ADD_OBJECT([o backgroundColor], @"Background color")
                        ADD_ENUM(TableViewColumnAutoresizingStyle, [o columnAutoresizingStyle], @"Column autoresizing style")
                        ADD_OBJECT([o cornerView], @"Corner view")
                        ADD_OBJECT([o dataSource], @"Data source")
                        ADD_OBJECT([o delegate], @"Delegate")
                        ADD_SEL([o doubleAction], @"Double action")
                        ADD_OBJECT([o gridColor], @"Grid color")
                        ADD_ENUM(TableViewGridLineStyle, [o gridStyleMask], @"Grid style mask")
                        ADD_OBJECT([o headerView], @"Header view")
                        ADD_OBJECT_NOT_NIL([o highlightedTableColumn], @"Highlighted table column")
                        ADD_SIZE([o intercellSpacing], @"Intercell spacing")
                        ADD_NUMBER([o numberOfColumns], @"Number of columns")
                        ADD_NUMBER([o numberOfRows], @"Number of rows")
                        ADD_NUMBER([o numberOfSelectedColumns], @"Number of selected columns")
                        ADD_NUMBER([o numberOfSelectedRows], @"Number of selected rows")
                        ADD_NUMBER([o rowHeight], @"Row height")
                        ADD_NUMBER([o selectedColumn], @"Selected column")
                        ADD_OBJECT([o selectedColumnIndexes], @"Selected column indexes")
                        ADD_NUMBER([o selectedRow], @"Selected row")
                        ADD_OBJECT([o selectedRowIndexes], @"Selected row indexes")
                        ADD_ENUM(TableViewSelectionHighlightStyle, [o selectionHighlightStyle], @"Selection highlight style")
                        ADD_OBJECTS([o sortDescriptors], @"Sort descriptors")
                        ADD_OBJECTS([o tableColumns], @"Table columns")
                        ADD_BOOL([o usesAlternatingRowBackgroundColors], @"Uses alternating row background colors")
                        ADD_BOOL([o verticalMotionCanBeginDrag], @"Vertical motion can begin drag")
                }
                else if ([object isKindOfClass:[NSStepper class]]) {
                        NSStepper* o = object;
                        ADD_CLASS_LABEL(@"NSStepper Info");
                        ADD_BOOL([o autorepeat], @"Autorepeat")
                        ADD_NUMBER([o increment], @"Increment")
                        ADD_NUMBER([o maxValue], @"Max value")
                        ADD_NUMBER([o minValue], @"Min value")
                        ADD_BOOL([o valueWraps], @"Value wraps")
                }
                else if ([object isKindOfClass:[NSTextField class]]) {
                        if ([object isKindOfClass:[NSComboBox class]]) {
                                NSComboBox* o = object;
                                ADD_CLASS_LABEL(@"NSComboBox Info");
                                if ([o usesDataSource])
                                        ADD_OBJECT([o dataSource], @"Data source")
                                ADD_BOOL([o hasVerticalScroller], @"Has vertical scroller")
                                ADD_NUMBER([o indexOfSelectedItem], @"Index of selected item")
                                ADD_SIZE([o intercellSpacing], @"Intercell spacing")
                                ADD_BOOL([o isButtonBordered], @"Is button bordered")
                                ADD_NUMBER([o itemHeight], @"Item height")
                                ADD_NUMBER([o numberOfItems], @"Number of items")
                                ADD_NUMBER([o numberOfVisibleItems], @"Number of visible items")
                                if (![o usesDataSource] && [o indexOfSelectedItem] != -1)
                                        ADD_OBJECT([o objectValueOfSelectedItem], @"Object value of selected item")
                                if (![o usesDataSource])
                                        ADD_OBJECTS([o objectValues], @"Object values")
                                ADD_BOOL([o usesDataSource], @"Uses data source")
                        }
                        else if ([object isKindOfClass:[NSSearchField class]]) {
                                NSSearchField* o = object;
                                if ([[o recentSearches] count] != 0 || [o recentsAutosaveName] != nil)
                                        ADD_CLASS_LABEL(@"NSSearchField Info");
                                ADD_OBJECTS([o recentSearches], @"Recent searches")
                                ADD_OBJECT_NOT_NIL([o recentsAutosaveName], @"Recents autosave name")
                        }
                        else if ([object isKindOfClass:[NSTokenField class]]) {
                                NSTokenField* o = object;
                                ADD_CLASS_LABEL(@"NSTokenField Info");
                                ADD_NUMBER([o completionDelay], @"Completion delay")
                                ADD_OBJECT([o tokenizingCharacterSet], @"Tokenizing character set")
                                ADD_ENUM(TokenStyle, [o tokenStyle], @"Token style")
                        }

                        NSTextField* o = object;
                        ADD_CLASS_LABEL(@"NSTextField Info");
                        ADD_BOOL([o allowsEditingTextAttributes], @"Allows editing text attributes")
                        ADD_OBJECT([o backgroundColor], @"Background color")
                        ADD_ENUM(TextFieldBezelStyle, [o bezelStyle], @"Bezel style")
                        ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                        ADD_BOOL([o drawsBackground], @"Draws background")
                        ADD_BOOL([o importsGraphics], @"Imports graphics")
                        ADD_BOOL([o isBezeled], @"Is bezeled")
                        ADD_BOOL([o isBordered], @"Is bordered")
                        ADD_BOOL([o isEditable], @"Is editable")
                        ADD_BOOL([o isSelectable], @"Is selectable")
                        ADD_OBJECT([o textColor], @"Text color")
                }

                NSControl* o = object;
                ADD_CLASS_LABEL(@"NSControl Info");
                ADD_SEL([o action], @"Action")
                ADD_ENUM(TextAlignment, [o alignment], @"Alignment")
                ADD_ENUM(WritingDirection, [o baseWritingDirection], @"Base writing direction")
                ADD_OBJECT([o cell], @"Cell")
                ADD_ENUM(ControlSize, [o controlSize], @"Control size")
                ADD_OBJECT_NOT_NIL([o currentEditor], @"Current editor")
                ADD_OBJECT([o font], @"Font")
                ADD_OBJECT([o formatter], @"Formatter")
                ADD_BOOL([o ignoresMultiClick], @"Ignores multiclick")
                ADD_BOOL([o isContinuous], @"Is continuous")
                ADD_BOOL([o isEnabled], @"Is enabled")
                if ([o currentEditor] == nil)
                        ADD_OBJECT([o objectValue], @"Object value") // To avoid side-effects, we only call objectValue if the control is not being edited, which is determined with the currentEditor call.
                ADD_BOOL([o refusesFirstResponder], @"Refuses first responder")
                ADD_OBJECT([o selectedCell], @"Selected cell")
                ADD_NUMBER([o selectedTag], @"Selected tag")
                ADD_OBJECT([o target], @"Target")
        }
}

- (void)processNSWindow:(id)object
{
        {
                if ([object isKindOfClass:[NSPanel class]]) {
                        if ([object isKindOfClass:[NSColorPanel class]]) {
                                NSColorPanel* o = object;
                                ADD_CLASS_LABEL(@"NSColorPanel Info");
                                ADD_OBJECT_NOT_NIL([o accessoryView], @"Accessory view")
                                ADD_NUMBER([o alpha], @"Alpha")
                                ADD_OBJECT([o color], @"Color")
                                ADD_BOOL([o isContinuous], @"Is continuous")
                                ADD_ENUM(ColorPanelMode, [o mode], @"Mode")
                                ADD_BOOL([o showsAlpha], @"Shows alpha")
                        }
                        else if ([object isKindOfClass:[NSFontPanel class]]) {
                                NSFontPanel* o = object;
                                ADD_CLASS_LABEL(@"NSFontPanel Info");
                                ADD_OBJECT_NOT_NIL([o accessoryView], @"Accessory view")
                                ADD_BOOL([o isEnabled], @"Is enabled")
                        }
                        else if ([object isKindOfClass:[NSSavePanel class]]) {
                                if ([object isKindOfClass:[NSOpenPanel class]]) {
                                        NSOpenPanel* o = object;
                                        ADD_CLASS_LABEL(@"NSOpenPanel Info");
                                        ADD_BOOL([o allowsMultipleSelection], @"Allows multiple selection")
                                        ADD_BOOL([o canChooseDirectories], @"Can choose directories")
                                        ADD_BOOL([o canChooseFiles], @"Can choose files")
                                        ADD_OBJECTS([o filenames], @"Filenames")
                                        ADD_BOOL([o resolvesAliases], @"Resolves aliases")
                                        ADD_OBJECTS([o URLs], @"URLs")
                                }

                                NSSavePanel* o = object;
                                ADD_CLASS_LABEL(@"NSSavePanel Info");
                                ADD_OBJECT_NOT_NIL([o accessoryView], @"Accessory view")
                                ADD_OBJECTS([o allowedFileTypes], @"Allowed file types")
                                ADD_BOOL([o allowsOtherFileTypes], @"Allows other file types")
                                ADD_BOOL([o canCreateDirectories], @"Can create directories")
                                ADD_BOOL([o canSelectHiddenExtension], @"Can select hidden extension")
                                ADD_OBJECT_NOT_NIL([o delegate], @"Delegate")
                                ADD_OBJECT([o directory], @"Directory")
                                ADD_OBJECT([o filename], @"Filename")
                                ADD_BOOL([o isExpanded], @"Is expanded")
                                ADD_BOOL([o isExtensionHidden], @"Is extension hidden")
                                ADD_OBJECT([o message], @"Message")
                                ADD_OBJECT([o nameFieldLabel], @"nameFieldLabel")
                                ADD_OBJECT([o prompt], @"Prompt")
                                ADD_BOOL([o treatsFilePackagesAsDirectories], @"Treats file packages as directories")
                                ADD_OBJECT([o URL], @"URL")
                        }


                        NSPanel* o = object;
                        ADD_CLASS_LABEL(@"NSPanel Info");
                        ADD_BOOL([o becomesKeyOnlyIfNeeded], @"Becomes key only if needed")
                        ADD_BOOL([o isFloatingPanel], @"Is floating panel")
                }

                NSWindow* o = object;
                ADD_CLASS_LABEL(@"NSWindow Info");
                ADD_BOOL([o acceptsMouseMovedEvents], @"Accepts mouse moved events")
                ADD_BOOL([o allowsToolTipsWhenApplicationIsInactive], @"Allows tool tips when application is inactive")
                ADD_NUMBER([o alphaValue], @"Alpha value")
                ADD_BOOL([o areCursorRectsEnabled], @"Are cursor rects enabled")
                ADD_SIZE([o aspectRatio], @"Aspect ratio")
                ADD_OBJECT_NOT_NIL([o attachedSheet], @"Attached sheet")
                ADD_BOOL([o autorecalculatesKeyViewLoop], @"Autorecalculates key view loop")
                ADD_ENUM(WindowBackingLocation, [o backingLocation], @"Backing location")
                ADD_OBJECT([o backgroundColor], @"Background color")
                ADD_ENUM(BackingStoreType, [o backingType], @"Backing type")
                ADD_BOOL([o canBecomeKeyWindow], @"Can become key window")
                ADD_BOOL([o canBecomeMainWindow], @"Can become main window")
                ADD_BOOL([o canBecomeVisibleWithoutLogin], @"Can become visible without login")
                ADD_BOOL([o canHide], @"Can hide")
                ADD_BOOL([o canStoreColor], @"Can store color")
                ADD_ENUM(WindowCollectionBehavior, [o collectionBehavior], @"Collection behavior")
                ADD_OBJECTS([o childWindows], @"Child windows")
                ADD_SIZE([o contentAspectRatio], @"Content aspect ratio")
                ADD_SIZE([o contentMaxSize], @"Content max size")
                ADD_SIZE([o contentMinSize], @"Content min size")
                ADD_SIZE([o contentResizeIncrements], @"Content resize increments")
                ADD_OBJECT([o contentView], @"Content view")
                ADD_OBJECT_NOT_NIL([o deepestScreen], @"Deepest screen")
                ADD_OBJECT([o defaultButtonCell], @"Default button cell")
                ADD_OBJECT([o delegate], @"Delegate")
                ADD_NUMBER([o depthLimit], @"Depth limit")
                ADD_DICTIONARY([o deviceDescription], @"Device description")
                ADD_BOOL([o displaysWhenScreenProfileChanges], @"Displays when screen profile changes")
                ADD_OBJECTS([o drawers], @"Drawers")
                ADD_OBJECT([o firstResponder], @"First responder")
                ADD_RECT([o frame], @"Frame")
                ADD_OBJECT_NOT_NIL([o frameAutosaveName], @"Frame autosave name")
                ADD_OBJECT([o graphicsContext], @"Graphics context")
                // Call to gState fails when the window in miniaturized
                //ADD_NUMBER(            [o gState]                             ,@"gState")
                ADD_BOOL([o hasDynamicDepthLimit], @"Has dynamic depth limit")
                ADD_BOOL([o hasShadow], @"Has shadow")
                ADD_BOOL([o hidesOnDeactivate], @"Hides on deactivate")
                ADD_BOOL([o ignoresMouseEvents], @"Ignores mouse events")
                ADD_OBJECT([o initialFirstResponder], @"Initial first responder")
                ADD_BOOL([o isAutodisplay], @"Is autodisplay")
                ADD_BOOL([o isDocumentEdited], @"Is document edited")
                ADD_BOOL([o isExcludedFromWindowsMenu], @"Is exclude from windowsmenu")
                ADD_BOOL([o isFlushWindowDisabled], @"Is flush window disabled")
                ADD_BOOL([o isMiniaturized], @"Is miniaturized")
                ADD_BOOL([o isMovableByWindowBackground], @"Is movable by window background")
                ADD_BOOL([o isOneShot], @"Is oneShot")
                ADD_BOOL([o isOpaque], @"Is opaque")
                ADD_BOOL([o isReleasedWhenClosed], @"Is released when closed")
                ADD_BOOL([o isSheet], @"Is sheet")
                ADD_BOOL([o isVisible], @"Is visible")
                ADD_BOOL([o isZoomed], @"Is zoomed")
                ADD_ENUM(SelectionDirection, [o keyViewSelectionDirection], @"Key view selection direction")
                ADD_ENUM(WindowLevel, [o level], @"Level")
                ADD_SIZE([o maxSize], @"Max size")
                ADD_SIZE([o minSize], @"Min size")
                ADD_OBJECT_NOT_NIL([o miniwindowImage], @"Miniwindow image")
                ADD_OBJECT([o miniwindowTitle], @"Miniwindow title")
                ADD_OBJECT_NOT_NIL([o parentWindow], @"Parent window")
                ADD_ENUM(WindowBackingLocation, [o preferredBackingLocation], @"Preferred backing location")
                ADD_BOOL([o preservesContentDuringLiveResize], @"Preserves content during live resize")
                ADD_OBJECT_NOT_NIL([o representedFilename], @"Represented filename")
                ADD_OBJECT_NOT_NIL([o representedURL], @"Represented URL")
                ADD_SIZE([o resizeIncrements], @"Resize increments")
                ADD_OBJECT([o screen], @"Screen")
                ADD_ENUM(WindowSharingType, [o sharingType], @"Sharing type")
                ADD_BOOL([o showsResizeIndicator], @"Shows resize indicator")
                ADD_BOOL([o showsToolbarButton], @"Shows toolbar button")
                ADD_ENUM(WindowMask, [o styleMask], @"Style mask")
                ADD_OBJECT([o title], @"Title")
                ADD_OBJECT_NOT_NIL([o toolbar], @"Toolbar")
                ADD_NUMBER([o userSpaceScaleFactor], @"User space scale factor")
                ADD_BOOL([o viewsNeedDisplay], @"Views need display")
                ADD_OBJECT_NOT_NIL([o windowController], @"Window controller")
                ADD_NUMBER([o windowNumber], @"Window number")
                ADD_BOOL([o worksWhenModal], @"Works when modal")
        }
}
@end
