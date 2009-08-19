package ch.unil.cbg.ExpressionView.view.components {
	
	import ch.unil.cbg.ExpressionView.events.SearchableDataGridSelectionEvent;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.controls.DataGrid;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.core.ScrollPolicy;
	import mx.events.DataGridEvent;
	import mx.events.ListEvent;

	[Event(name='ITEM_CLICK', type='ch.unil.cbg.ExpressionView.events.SearchableDataGridSelectionEvent')]
	[Event(name='ITEM_DOUBLE_CLICK', type='ch.unil.cbg.ExpressionView.events.SearchableDataGridSelectionEvent')]
	public class SearchableDataGrid extends Canvas implements IEventDispatcher {

		private var dataprovider:XMLListCollection = new XMLListCollection();
		private var datagridcolumns:DataGridColumn = new DataGridColumn();
		private var dataGrid:DataGrid;
		
		private var headerBox:HBox;
		protected var searchField:TextInput;
		private var searchText:Text;
		
		private var alt:Boolean;
		private var searchColumn:int;
		
		private var optimalWidths:Array;
		
		public function SearchableDataGrid() {
			super();
			searchColumn = -1;
			alt = false;
			optimalWidths = new Array();
		}

		override protected function createChildren() : void{
			
			super.createChildren();
			super.horizontalScrollPolicy = "off";
			super.verticalScrollPolicy = "off";

			if ( !headerBox ) {
				headerBox = new HBox();
				headerBox.setStyle("verticalAlign", "middle");
				addChild(headerBox);
					
				if ( !searchText ) {
					searchText = new Text();
					searchText.text = "Find";
					headerBox.addChild(searchText);
				}

				if ( !searchField ) {
					searchField = new TextInput();
					searchField.addEventListener(Event.CHANGE, handleChange);
					headerBox.addChild(searchField);
				}
			}
				
			if ( !dataGrid ) {
				dataGrid = new DataGrid();
				dataGrid.verticalScrollPolicy = ScrollPolicy.AUTO;
				dataGrid.horizontalScrollPolicy = ScrollPolicy.AUTO;
				dataGrid.allowMultipleSelection = true;
				dataGrid.doubleClickEnabled = true;
				dataGrid.addEventListener(ListEvent.ITEM_CLICK, clickHandler);
				dataGrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, doubleClickHandler);
				dataGrid.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				dataGrid.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				dataGrid.addEventListener(KeyboardEvent.KEY_UP, keyUHandler);
				dataGrid.addEventListener(DataGridEvent.HEADER_RELEASE, headerReleaseHandler);
				addChild(dataGrid);
			}
		}
		
		private function getSelection(selected:Array): Array {
			var selection:Array = [];
			for ( var i:int = 0; i < selected.length; ++ i ) {
				selection.push(dataprovider[selected[i]].children()[0])
			}
			return selection;
		}
		
		private function headerReleaseHandler(event:DataGridEvent):void {
			if ( alt ) {
				event.preventDefault();
				if ( event.columnIndex != searchColumn ) {
					if ( searchColumn != -1 ) {
						dataGrid.columns[searchColumn].headerText = dataGrid.columns[searchColumn].headerText.slice(0,
																		dataGrid.columns[searchColumn].headerText.length-1);
					}
					searchColumn = event.columnIndex;
					searchText.text = "Find in " + dataGrid.columns[searchColumn].headerText;
					dataGrid.columns[searchColumn].headerText = dataGrid.columns[searchColumn].headerText + "*"; 
				} else {
					dataGrid.columns[searchColumn].headerText = dataGrid.columns[searchColumn].headerText.slice(0,
																		dataGrid.columns[searchColumn].headerText.length-1);
					searchColumn = -1;
					searchText.text = "Find";
				}
			}
		}
		
		private function clickHandler(event:ListEvent): void {
			dispatchEvent(new SearchableDataGridSelectionEvent(SearchableDataGridSelectionEvent.ITEM_CLICK, getSelection(dataGrid.selectedIndices)));
		}
		
		private function doubleClickHandler(event:ListEvent): void {
			dispatchEvent(new SearchableDataGridSelectionEvent(SearchableDataGridSelectionEvent.ITEM_DOUBLE_CLICK, getSelection(dataGrid.selectedIndices)));
		}

		private function mouseDownHandler(event:MouseEvent): void {
			if ( event.altKey ) {
				alt = true;
			}
		}		
		private function mouseUpHandler(event:MouseEvent): void {
			alt = false;
		}		

		private function keyUHandler(event:KeyboardEvent): void {
			// 40 = down arrow, 38 = up arrow
			if ( event.keyCode == 40  || event.keyCode == 38) {
				dispatchEvent(new SearchableDataGridSelectionEvent(SearchableDataGridSelectionEvent.ITEM_CLICK, getSelection(dataGrid.selectedIndices)));
			}
			// 65 = a
			if ( event.ctrlKey && event.keyCode == 65 ) {
				var selection:Array = [];
				for ( var i:int = 0; i < dataprovider.length; ++i ) {
					selection.push(i);
				}
				dataGrid.selectedIndices = selection;
				dispatchEvent(new SearchableDataGridSelectionEvent(SearchableDataGridSelectionEvent.ITEM_CLICK, getSelection(dataGrid.selectedIndices)));
			}
			// 73 = i
			if ( event.ctrlKey && event.keyCode == 73 ) {
				var oldselection:Array = dataGrid.selectedIndices; 
				var newselection:Array = [];
				for ( i = 0; i < dataprovider.length; ++i ) {
					if ( oldselection.indexOf(i, 0) == -1 ) {
						newselection.push(i);
					}
				}
				dataGrid.selectedIndices = newselection;
				dispatchEvent(new SearchableDataGridSelectionEvent(SearchableDataGridSelectionEvent.ITEM_CLICK, getSelection(dataGrid.selectedIndices)));				
			}
		}		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {		
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			searchField.width = parent.width - searchText.width;
			
			headerBox.x = 0; 
			headerBox.y = 0;
			headerBox.percentWidth = 100;
			headerBox.height = 30;
			
			dataGrid.x = 0;
			dataGrid.y = headerBox.height;
			dataGrid.width = unscaledWidth;
			dataGrid.height = unscaledHeight - headerBox.height;
			
			for ( var col:int = 0; col < optimalWidths.length; ++col ) {
				var width:Number = optimalWidths[col]; 
				if ( width > -1 ) {
					dataGrid.columns[col].width = optimalWidths[col] + 20;
				}
			}
						
		}


		private function handleChange(e:Event) : void{
            if (searchField.text.length == 0) {
                dataprovider.filterFunction = null;
            } else {
                dataprovider.filterFunction = filterFunction;
            }
            dataprovider.refresh();			
		}
		
		
		private function filterFunction(item:Object) : Boolean {
            if ( searchField.text.length == 0 ) {
            	return true;
            }
            var f:String = "ig";
            var i:int = 0;
            var regExp:RegExp = new RegExp(searchField.text, f);
            if ( searchColumn != -1 ) {
				var column:String = dataGrid.columns[searchColumn].dataField;
				var match:Boolean = regExp.test(item.descendants(column))
				if ( match ) {
					return true;
				}
            } else {
	            for ( i; i < dataGrid.columns.length; ++i ) {
					column = dataGrid.columns[i].dataField;
					match = regExp.test(item.descendants(column))
					if ( match ) {
						return true;
					}
	            }
			}
            return false;
		}
		
		public function set dataProvider(value:Object):void{
			dataprovider = value as XMLListCollection;
			dataGrid.dataProvider = dataprovider;
		}
		
		public function set columns(value:Object):void {
			dataGrid.columns = value as Array;
			calculateOptimalWidths();
		}
		
		private function calculateOptimalWidths():void {
			optimalWidths = new Array(dataGrid.columnCount);
			for ( var col:int = 0; col < dataGrid.columnCount; ++col ) {
				optimalWidths[col] = -1;
			}
			for ( col = 0; col < dataGrid.columnCount; ++col ) {
				var renderer:DataGridItemRenderer = new DataGridItemRenderer();
				for each ( var item:Object in dataprovider ) {
					renderer.text = dataGrid.columns[col].itemToLabel(item);
					optimalWidths[col] = Math.max(renderer.measuredWidth, optimalWidths[col]);
				}
				renderer.text = dataGrid.columns[col].headerText;
				optimalWidths[col] = Math.max(renderer.measuredWidth, optimalWidths[col]);
			}
			invalidateDisplayList();
		}
		
	}
}