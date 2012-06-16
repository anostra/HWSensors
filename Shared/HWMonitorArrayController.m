//
//  HWMonitorArrayController.m
//  HWSensors
//
//  Created by Kozlek on 16.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HWMonitorArrayController.h"

@implementation HWMonitorArrayController

@synthesize tableView = _tableView;

#define kHWMonitorTableViewDataType @"kHWMonitorTableViewDataType"

-(id)init
{
    return self;
}

-(void)setFirstFavoriteItem:(NSString*)favoriteName firstAvailableItem:(NSString*)availableName;
{
    if ([[self arrangedObjects] count] > 0)
        [[self arrangedObjects] removeAllObjects];
    
    _firstFavoriteItem = [NSDictionary dictionaryWithObjectsAndKeys:favoriteName, @"Name", nil];
    _firstAvailableItem = [NSDictionary dictionaryWithObjectsAndKeys:availableName, @"Name", nil];
    
    [self insertObject:_firstFavoriteItem atArrangedObjectIndex:0];
    [self insertObject:_firstAvailableItem atArrangedObjectIndex:1];
}

-(NSDictionary*)addFavoriteItem:(NSString*)name icon:(NSImage*)icon key:(NSString*)key
{
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", icon, @"Icon", key, @"Key", nil];
    
    [self insertObject:item atArrangedObjectIndex:[[self arrangedObjects] indexOfObject:_firstAvailableItem]];
    
    return item;
}

-(NSDictionary*)addAvailableItem:(NSString*)name icon:(NSImage*)icon key:(NSString*)key
{
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", icon, @"Icon", key, @"Key", nil];
    
    [self addObject:item];
    
    return item;
}

-(NSArray*)getFavoritesItems
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
 
    NSUInteger index;
    
    for (index = 1; index < [[self arrangedObjects] count]; index++) {
        
        NSDictionary *item = [[self arrangedObjects] objectAtIndex:index];
        
        if (_firstAvailableItem != item)
            [list addObject:item];
        else
            break;
    }
    
    return list;
}

-(void)setupController
{
    [_tableView registerForDraggedTypes:[NSArray arrayWithObject:kHWMonitorTableViewDataType]];
	[_tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
}

-(NSDictionary*)addItemWithName:(NSString*)name icon:(NSImage*)icon key:(NSString*)key
{
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", icon, @"Icon", key, @"Key", nil];
    
    [self addObject:item];
    
    return item;
}

- (void) awakeFromNib {
	[self setupController];
}

// ===========================================
// NSTableView data managing
// ===========================================

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return nil != [[[self arrangedObjects] objectAtIndex:row] valueForKey:@"Icon"];
}

/*- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    if ([proposedSelectionIndexes count] > 0 && [[[self arrangedObjects] objectAtIndex:[proposedSelectionIndexes firstIndex]] valueForKey:@"Icon"]) {
        return [NSIndexSet indexSetWithIndex:[proposedSelectionIndexes firstIndex]];
    }
    
    return [NSIndexSet indexSet];
}*/

// ===========================================
// NSTableView drag & drop support
// ===========================================

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
{
    //[_tableView selectRowIndexes:rowIndexes byExtendingSelection:YES];
    
    if ([rowIndexes count] == 0 || ![[[self arrangedObjects] objectAtIndex:[rowIndexes firstIndex]] valueForKey:@"Icon"]) 
        return NO;
    
    NSData *indexData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    
    [pboard declareTypes:[NSArray arrayWithObject:kHWMonitorTableViewDataType] owner:self];
    [pboard setData:indexData forType:kHWMonitorTableViewDataType];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation;
{
    return row > 0 ? NSDragOperationEvery : NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation;
{
    //this is the code that handles dnd ordering - my table doesn't need to accept drops from outside! Hooray!
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:kHWMonitorTableViewDataType];
    
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
    int from = [rowIndexes firstIndex];
    
    NSMutableDictionary *traveller = [[self arrangedObjects] objectAtIndex:from];
    
    //[traveller retain];
    
    NSUInteger length = [[self arrangedObjects] count];
    
    NSMutableArray *replacement = [NSMutableArray new];
    
    int i;
    for (i = 0; i <= length; i++){
        if(i == row){
            if(from > row){
                [self insertObject:traveller atArrangedObjectIndex:row];
                [self removeObjectAtArrangedObjectIndex:from+1];
            }
            else{
                [self insertObject:traveller atArrangedObjectIndex:row];
                [self removeObjectAtArrangedObjectIndex:from];
            }
        }
    }
    
    [_tableView noteNumberOfRowsChanged];
    [_tableView reloadData];
    
    return YES;
}

@end