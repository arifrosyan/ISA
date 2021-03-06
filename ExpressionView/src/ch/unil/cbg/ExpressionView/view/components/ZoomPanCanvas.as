//     ExpressionView - A package to visualize biclusters
//     Copyright (C) 2009 Computational Biology Group, University of Lausanne
// 
//     This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.
// 
//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//     GNU General Public License for more details.
// 
//     You should have received a copy of the GNU General Public License
//     along with this program.  If not, see <http://www.gnu.org/licenses/>.

package ch.unil.cbg.ExpressionView.view.components {
	
	import __AS3__.vec.Vector;
	
	import ch.unil.cbg.ExpressionView.events.*;
	import ch.unil.cbg.ExpressionView.model.*;
	import ch.unil.cbg.ExpressionView.utilities.LargeBitmapData;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;	
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.containers.Canvas;
	import mx.controls.ButtonBar;
	import mx.controls.HScrollBar;
	import mx.controls.Image;
	import mx.controls.VScrollBar;
	import mx.events.ItemClickEvent;
	import mx.events.ScrollEvent;
	import mx.controls.Alert;


	public class ZoomPanCanvas extends Canvas {

		[Embed(source='/ch/unil/cbg/ExpressionView/assets/menu/zoomin.png')]
		private var zoomInIcon:Class; 
		[Embed(source='/ch/unil/cbg/ExpressionView/assets/menu/zoomout.png')]
		private var zoomOutIcon:Class; 
		[Embed(source='/ch/unil/cbg/ExpressionView/assets/menu/zoomauto.png')]
		private var zoomAutoIcon:Class; 
		[Embed(source='/ch/unil/cbg/ExpressionView/assets/menu/zoomautox.png')]
		private var zoomAutoXIcon:Class; 
		[Embed(source='/ch/unil/cbg/ExpressionView/assets/menu/zoomautoy.png')]
		private var zoomAutoYIcon:Class; 
		[Embed(source='/ch/unil/cbg/ExpressionView/assets/menu/zoomall.png')]
		private var zoomAllIcon:Class; 

		private const MINIMAL_WIDTH:int = 2;
		private const MINIMAL_HEIGHT:int = 2;
	
		private static const INSPECT:int = 0;
    	private static const ZOOM:int = 1;
    	private static const PAN:int = 2;
	
		private var fullgeimage:LargeBitmapData;
		private var fullmodulesimage:LargeBitmapData;
		private var maximalWidth:int = 0;
		private var maximalHeight:int = 0;
		private var modulesWidth:int;
		private var modulesHeight:int;
		
		private var currentgeimage:Bitmap;
		private var currentmodulesimage:Bitmap;		
				
		private var lastMode:int;
		
		private var lastPt:Point;
		private var currentRectangle:Rectangle;
		private var lastRectangle:Rectangle;
		private var selectionRectangle:Rectangle;
		private var selection:Shape;
		
		private var selectedGene:int;
		private var selectedSample:int;
		
		private var modulesOutlines:Array;
		private var modulesColors:Vector.<Array>;
		
		private var lastClick:int;
		
		private var highlighting:Boolean = true;
		private var highlightedModules:Array;
		private var highlightedGenes:Array;
		private var highlightedSamples:Array;
		
		
		// layout
		private var canvaswidth:Number;
		private var canvasheight:Number;
		private var hscrollbar:HScrollBar;
		private var vscrollbar:VScrollBar;		
		private var geimage:Image;
		private var modulesimage:Image;
		private var modulesCanvas:Canvas;
		private var highlightCanvas:Canvas;
		private var overlayCanvas:Canvas;
		private var zoomMenu:ButtonBar;
		
		public function ZoomPanCanvas() {
			super();
			lastRectangle = new Rectangle();
			lastPt = new Point();
			
			currentgeimage = new Bitmap();
			currentmodulesimage = new Bitmap();
						
			lastMode = 0;
			
			canvaswidth = this.width;
			canvasheight = this.height;
			
			highlightedModules = [];
			highlightedGenes = [];
			highlightedSamples = [];
		}
		
		private function modeChangeHandler(event:MenuEvent):void {
			var mode:int = event.data[0];
			if ( mode != lastMode ) {
				if ( lastMode == INSPECT ) {
					// show position also while zooming and panning
					//overlayCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, inspectMouseMoveHandler);
					//overlayCanvas.removeEventListener(MouseEvent.MOUSE_OUT, inspectMouseOutHandler);
					overlayCanvas.removeEventListener(MouseEvent.CLICK, inspectMouseClickHandler);
				} else if ( lastMode == ZOOM ) {
					overlayCanvas.removeEventListener(MouseEvent.MOUSE_DOWN, zoomMouseDownHandler);
					overlayCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, zoomMouseMoveHandler);
					overlayCanvas.removeEventListener(MouseEvent.MOUSE_UP, zoomMouseUpHandler);
					parentApplication.removeEventListener(KeyboardEvent.KEY_UP, zoomKeyUpHandler);
					zoomMenu.visible = false;
					dispatchEvent(new UpdateStatusBarEvent("")); 
				} else if ( lastMode == PAN ) {
					overlayCanvas.removeEventListener(MouseEvent.MOUSE_UP, dragMouseUpHandler);
					overlayCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, dragMouseMoveHandler);
					overlayCanvas.removeEventListener(MouseEvent.MOUSE_DOWN, dragMouseDownHandler);					
				}
				
				if ( mode == INSPECT ) {
					overlayCanvas.addEventListener(MouseEvent.MOUSE_MOVE, inspectMouseMoveHandler);
					overlayCanvas.addEventListener(MouseEvent.MOUSE_OUT, inspectMouseOutHandler);
					overlayCanvas.addEventListener(MouseEvent.CLICK, inspectMouseClickHandler);
				}
				else if ( mode == ZOOM ) {
					overlayCanvas.addEventListener(MouseEvent.MOUSE_DOWN, zoomMouseDownHandler);
					parentApplication.addEventListener(KeyboardEvent.KEY_UP, zoomKeyUpHandler);
					zoomMenu.visible = true;
					dispatchEvent(new UpdateStatusBarEvent("click to zoom in, shift-click to zoom out, a to autozoom on modules, e to see everything.")); 
				} else if ( mode == PAN ) {
					overlayCanvas.addEventListener(MouseEvent.MOUSE_DOWN, dragMouseDownHandler);
				}
			}
			lastMode = mode;
		}

		private function adjustRectangle(rect: Rectangle): Rectangle {
			var r:Rectangle = rect.clone();
						
			// width and height
			if ( r.width > maximalWidth ) { r.width = maximalWidth }
			if ( r.height > maximalHeight ) { r.height = maximalHeight }
			if ( r.width < MINIMAL_WIDTH ) { r.width = MINIMAL_WIDTH }
			if ( r.height < MINIMAL_WIDTH ) { r.height = MINIMAL_HEIGHT }
			
			// position
			if ( r.x < 0 ) { r.x = 0 }
			if ( r.y < 0 ) { r.y = 0 }
			if ( r.bottomRight.x > maximalWidth ) { r.x -= (r.bottomRight.x - maximalWidth) }
			if ( r.bottomRight.y > maximalHeight ) { r.y -= (r.bottomRight.y - maximalHeight) }

			return r;
		}

		// inspect events
		private function inspectMouseMoveHandler(event:MouseEvent):void {
			var gene:int = currentRectangle.x + event.localX / canvaswidth * currentRectangle.width;
			var sample:int = currentRectangle.y + event.localY / canvasheight * currentRectangle.height;
			dispatchEvent(new BroadcastPositionEvent(BroadcastPositionEvent.MOUSE_OVER, [gene, sample]));			
		}
		private function inspectMouseOutHandler(event:MouseEvent):void {
			dispatchEvent(new BroadcastPositionEvent(BroadcastPositionEvent.MOUSE_OVER, [-1, -1]));			
		}
		private function inspectMouseClickHandler(event:MouseEvent):void {
			var gene:int = currentRectangle.x + event.localX / canvaswidth * currentRectangle.width;
			var sample:int = currentRectangle.y + event.localY / canvasheight * currentRectangle.height;
			dispatchEvent(new BroadcastPositionEvent(BroadcastPositionEvent.MOUSE_CLICK, [gene, sample]));
		}

		// zoom events
		private function zoomMouseDownHandler(event:MouseEvent): void {
			lastClick = getTimer();
			overlayCanvas.addEventListener(MouseEvent.MOUSE_MOVE, zoomMouseMoveHandler);
			overlayCanvas.addEventListener(MouseEvent.MOUSE_UP, zoomMouseUpHandler);
			selectionRectangle = new Rectangle(event.localX, event.localY);
			selection = new Shape();
			overlayCanvas.rawChildren.addChild(selection);
		}
		private function zoomMouseMoveHandler(event:MouseEvent): void {
			overlayCanvas.rawChildren.removeChild(selection);
			selection = new Shape();
			selection.alpha = 0.3;
			selectionRectangle.bottomRight = new Point(event.localX, event.localY);
			selection.graphics.beginFill(0xffff00);
			//selection.graphics.beginFill(0xaaccee);
			selection.graphics.drawRect(selectionRectangle.x, selectionRectangle.y, selectionRectangle.width, selectionRectangle.height); 
			selection.graphics.endFill();
			overlayCanvas.rawChildren.addChild(selection);
		}
		private function zoomMouseUpHandler(event:MouseEvent): void {
			overlayCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, zoomMouseMoveHandler);
			overlayCanvas.removeEventListener(MouseEvent.MOUSE_UP, zoomMouseUpHandler);
			overlayCanvas.removeEventListener(MouseEvent.MOUSE_DOWN, zoomMouseDownHandler);
			if ( getTimer() - lastClick > 200 ) {
				overlayCanvas.rawChildren.removeChild(selection);
	
				var x:Number = currentRectangle.x + selectionRectangle.x / canvaswidth * currentRectangle.width;
				var y:Number = currentRectangle.y + selectionRectangle.y / canvasheight * currentRectangle.height;
				var width:Number = selectionRectangle.width * currentRectangle.width / canvaswidth;
				var height:Number = selectionRectangle.height * currentRectangle.height / canvasheight;
				
				if ( width < 0 ) {
					width *= -1;
					x -= width;
				}
				if ( height < 0 ) {
					height *= -1;
					y -= height;
				}
				
				if ( width != 0 && height != 0 ) { 				
					currentRectangle = new Rectangle(int(x), int(y), int(width)+1, int(height)+1);
					currentRectangle = adjustRectangle(currentRectangle);
				
					drawImage();
					lastRectangle = currentRectangle.clone();
				}
			} else {
				var zoomfactor:Number = 0.5;
				if ( event.shiftKey ) {
					zoomfactor = 1. / zoomfactor;
				}
				var localPt:Point = new Point(event.localX, event.localY);
				currentRectangle = lastRectangle.clone();
	
				var newWidth:int = int(currentRectangle.width * zoomfactor);
				var newHeight:int = int(currentRectangle.height * zoomfactor);
				currentRectangle.width = newWidth;
				currentRectangle.height = newHeight;
				var offsetx:int = int( localPt.x / canvaswidth * lastRectangle.width - newWidth / 2 );
				var offsety:int = int( localPt.y / canvasheight * lastRectangle.height - newHeight / 2 );
				currentRectangle.offset(offsetx, offsety);
				currentRectangle = adjustRectangle(currentRectangle);

				drawImage();
				lastRectangle = currentRectangle.clone();		
			}
			overlayCanvas.addEventListener(MouseEvent.MOUSE_DOWN, zoomMouseDownHandler);
		}
		private function zoomKeyUpHandler(event:KeyboardEvent): void {
			var focus:String = getFocus().name;
			if ( focus.search("TextField") == -1 ) {
				// a
				if ( event.keyCode == 65 ) {
					if ( modulesWidth > 0 && modulesHeight > 0 ) {
						currentRectangle = new Rectangle(0, 0, modulesWidth, modulesHeight);
						currentRectangle = adjustRectangle(currentRectangle);
						drawImage();
						lastRectangle = currentRectangle.clone();
					}		
				}
				// g
				if ( event.keyCode == 71 ) {
					if ( modulesWidth > 0 ) {
						currentRectangle = new Rectangle(0, 0, modulesWidth, currentRectangle.height);
						currentRectangle = adjustRectangle(currentRectangle);
						drawImage();
						lastRectangle = currentRectangle.clone();
					}		
				}
				// s
				if ( event.keyCode == 83 ) {
					if ( modulesHeight > 0 ) {
						currentRectangle = new Rectangle(0, 0, currentRectangle.width, modulesHeight);
						currentRectangle = adjustRectangle(currentRectangle);
						drawImage();
						lastRectangle = currentRectangle.clone();
					}		
				}
				// e
				if ( event.keyCode == 69 ) {
					if ( modulesHeight > 0 ) {
						currentRectangle = new Rectangle(0, 0, maximalWidth, maximalHeight);
						currentRectangle = adjustRectangle(currentRectangle);
						drawImage();
						lastRectangle = currentRectangle.clone();
					}		
				}
			}
		}

		// drag events
		private function dragMouseDownHandler(event:MouseEvent): void {
			var pt:Point = new Point(event.localX, event.localY);
			lastPt = pt;
			overlayCanvas.addEventListener(MouseEvent.MOUSE_MOVE, dragMouseMoveHandler);
			overlayCanvas.addEventListener(MouseEvent.MOUSE_UP, dragMouseUpHandler);
			overlayCanvas.removeEventListener(MouseEvent.MOUSE_DOWN, dragMouseDownHandler);
			currentRectangle = lastRectangle.clone();
		}
		private function dragMouseMoveHandler(event:MouseEvent): void {
			var pt:Point = new Point(event.localX, event.localY);
			currentRectangle = lastRectangle.clone();
			var offsetx:int = int( (lastPt.x - pt.x) / canvaswidth * currentRectangle.width );
			var offsety:int = int( (lastPt.y - pt.y) / canvasheight * currentRectangle.height );
			currentRectangle.offset(offsetx, offsety);
			
			currentRectangle = adjustRectangle(currentRectangle);
			drawImage();
			hscrollbar.scrollPosition = currentRectangle.x;
			vscrollbar.scrollPosition = currentRectangle.y;
		}
		private function dragMouseUpHandler(event:MouseEvent): void {
			var pt:Point = new Point(event.localX, event.localY);
			currentRectangle = lastRectangle.clone();
			var offsetx:int = int( (lastPt.x - pt.x) / canvaswidth * currentRectangle.width );
			var offsety:int = int( (lastPt.y - pt.y) / canvasheight * currentRectangle.height );
			currentRectangle.offset(offsetx, offsety);
			currentRectangle = adjustRectangle(currentRectangle);
			drawImage();
			lastRectangle = currentRectangle.clone();

			hscrollbar.scrollPosition = currentRectangle.x;
			vscrollbar.scrollPosition = currentRectangle.y;
			overlayCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, dragMouseMoveHandler);
			overlayCanvas.removeEventListener(MouseEvent.MOUSE_UP, dragMouseUpHandler);
			overlayCanvas.addEventListener(MouseEvent.MOUSE_DOWN, dragMouseDownHandler);						
		}
		private function hScrollHandler(event:ScrollEvent): void {
			var dx:Number = event.currentTarget.scrollPosition - currentRectangle.x;
			currentRectangle.offset(dx, 0);
			currentRectangle = adjustRectangle(currentRectangle);
			drawImage();
			lastRectangle = currentRectangle.clone();
		}
		
		private function vScrollHandler(event:ScrollEvent): void {
			var dy:Number = event.currentTarget.scrollPosition - currentRectangle.y; 
			currentRectangle.offset(0, dy);
			currentRectangle = adjustRectangle(currentRectangle);
			drawImage();
			lastRectangle = currentRectangle.clone();
		}

		private function drawRectangles(): void {
			if ( canvaswidth > 0 ) {
				modulesCanvas.graphics.clear();
				var r:Rectangle;
				var x:Number; var y:Number; var dx:Number; var dy:Number;
				for ( var module:int = 1; module < modulesOutlines.length; ++module ) {
					r = currentRectangle.intersection(modulesOutlines[module]);
					if ( r.width > 0 && r.height > 0 ) {
						var scalex:Number = canvaswidth / currentRectangle.width;
						var scaley:Number = canvasheight / currentRectangle.height;
						x = (r.x - currentRectangle.x) * scalex;
						y = (r.y - currentRectangle.y) * scaley;
						dx = r.width * scalex;
						dy = r.height * scaley;
						modulesCanvas.graphics.lineStyle(2, modulesColors[module][1]);
						modulesCanvas.graphics.drawRect(x, y, dx, dy);
					}
				}
			}
		}

		private function drawImage(): void {
			drawRectangles();
			var targetRect:Rectangle = new Rectangle(0, 0, canvaswidth, canvasheight);
			currentgeimage.bitmapData = fullgeimage.getData(currentRectangle, targetRect);
			currentmodulesimage.bitmapData = fullmodulesimage.getData(currentRectangle, targetRect);
			if ( highlighting ) {
				dispatchEvent(new HighlightingEvent(HighlightingEvent.MODULE, [highlightedModules]));
			}
			dispatchEvent(new HighlightingEvent(HighlightingEvent.GENE, [highlightedGenes]));
			dispatchEvent(new HighlightingEvent(HighlightingEvent.SAMPLE, [highlightedSamples]));
			updateScrollBars();
 		}
 		
		override protected function createChildren(): void {
			
			super.createChildren();
			
			if ( !modulesimage ) {
				modulesimage = new Image();
				modulesimage.maintainAspectRatio = false;
				modulesimage.source = currentmodulesimage;
				addChild(modulesimage);
			}

			if ( !geimage ) {
				geimage = new Image();
				geimage.maintainAspectRatio = false;
				geimage.source = currentgeimage;
				geimage.alpha = 0.4;
				addChild(geimage);
			}

			if ( !modulesCanvas ) {
				modulesCanvas = new Canvas();
				addChild(modulesCanvas);
			}
				
			if ( !highlightCanvas ) {
				highlightCanvas = new Canvas();
				highlightCanvas.alpha = 1;
				addChild(highlightCanvas);
			}

			if ( !hscrollbar ) {
				hscrollbar = new HScrollBar();
				hscrollbar.addEventListener(ScrollEvent.SCROLL, hScrollHandler);
				addChild(hscrollbar);
			}

			if ( !vscrollbar ) {
				vscrollbar = new VScrollBar();
				vscrollbar.addEventListener(ScrollEvent.SCROLL, vScrollHandler);
				addChild(vscrollbar);
			}

			if ( !overlayCanvas ) {
				overlayCanvas = new Canvas();
				overlayCanvas.setStyle("backgroundAlpha",0);
				overlayCanvas.setStyle("backgroundColor","#FFFFFF");
				//overlayCanvas.alpha = 1;
				overlayCanvas.addEventListener(MouseEvent.MOUSE_MOVE, inspectMouseMoveHandler);
				overlayCanvas.addEventListener(MouseEvent.MOUSE_OUT, inspectMouseOutHandler);
				overlayCanvas.addEventListener(MouseEvent.CLICK, inspectMouseClickHandler);
				addChild(overlayCanvas);
			}
			
			if ( !zoomMenu ) {
				zoomMenu = new ButtonBar();
				zoomMenu.visible = false;
				zoomMenu.direction = "vertical";			
				
				var buttons:Array = [];
				var item:Object = new Object();
				item.label = "+";
				item.icon = zoomInIcon;
				item.toolTip = "Zoom in.";
				buttons.push(item);
				item = new Object();
				item.icon = zoomOutIcon;
				item.toolTip = "Zoom out.";
				buttons.push(item);
				item = new Object();
				item.icon = zoomAutoIcon;
				item.toolTip = "Auto zoom on modules";
				buttons.push(item);
				item = new Object();
				item.icon = zoomAutoXIcon;
				item.toolTip = "Auto zoom on modules along horizontal axis.";
				buttons.push(item);
				item = new Object();
				item.icon = zoomAutoYIcon;
				item.toolTip = "Auto zoom on modules along vertical axis.";
				buttons.push(item);
				item = new Object();
				item.icon = zoomAllIcon;
				item.toolTip = "Show everything.";
				buttons.push(item);
				zoomMenu.dataProvider = buttons;
				
				zoomMenu.addEventListener(ItemClickEvent.ITEM_CLICK, zoomMenuClickHandler);
				addChild(zoomMenu);				
			}
						
			parentApplication.addEventListener(MenuEvent.ALPHA, alphaSliderChangeHandler);
			parentApplication.addEventListener(MenuEvent.HIGHLIGHTING, setHighlightingVisibilityHandler);
			parentApplication.addEventListener(MenuEvent.OUTLINE, setOutlineVisibilityHandler);
			parentApplication.addEventListener(MenuEvent.FILLING, setFillingVisibilityHandler);
			parentApplication.addEventListener(HighlightingEvent.MODULE, highlightModulesHandler);
			parentApplication.addEventListener(HighlightingEvent.GENE, highlightGenesHandler);
			parentApplication.addEventListener(HighlightingEvent.SAMPLE, highlightSamplesHandler);			
		}

		private function zoomMenuClickHandler(event:ItemClickEvent): void {
			if ( event.index == 0 ) {
				overlayCanvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, overlayCanvas.height/2, overlayCanvas.width/2, null, false, false, false));
				overlayCanvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, overlayCanvas.height/2, overlayCanvas.width/2, null, false, false, false));
			} else if ( event.index == 1 ) {
				overlayCanvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, overlayCanvas.height/2, overlayCanvas.width/2, null, false, false, true));
				overlayCanvas.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, overlayCanvas.height/2, overlayCanvas.width/2, null, false, false, true));
			} else if ( event.index == 2 ) {
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 65));
			} else if ( event.index == 3 ) {
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 71));
			} else if ( event.index == 4 ) {
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 83));
			} else if ( event.index == 5 ) {
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 69));
			}
		}

		private function updateScrollBars():void {
			hscrollbar.minScrollPosition = 0
			hscrollbar.maxScrollPosition = maximalWidth - currentRectangle.width;
			hscrollbar.pageSize = currentRectangle.width;
			hscrollbar.lineScrollSize = currentRectangle.width / 4; 
        	hscrollbar.pageScrollSize =  currentRectangle.width * 3 / 4;
			hscrollbar.scrollPosition = currentRectangle.x; 

			vscrollbar.minScrollPosition = 0
			vscrollbar.maxScrollPosition = maximalHeight - currentRectangle.height;
			vscrollbar.pageSize = currentRectangle.height;
			vscrollbar.lineScrollSize = currentRectangle.height / 4; 
        	vscrollbar.pageScrollSize =  currentRectangle.height * 3 / 4;
			vscrollbar.scrollPosition =  currentRectangle.y;			
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var thickness:Number = 16;
			canvaswidth = unscaledWidth - thickness;
			canvasheight = unscaledHeight - thickness;

			geimage.width = canvaswidth;
			geimage.height = canvasheight;
			modulesimage.width = canvaswidth;
			modulesimage.height = canvasheight;
			modulesCanvas.width = canvaswidth;
			modulesCanvas.height = canvasheight;
			overlayCanvas.width = canvaswidth;
			overlayCanvas.height = canvasheight;
			zoomMenu.width = 40;
			zoomMenu.height = 220;
			zoomMenu.x = overlayCanvas.width - 3/2 * zoomMenu.width;
			zoomMenu.y = zoomMenu.width / 2;
						
			hscrollbar.width = canvaswidth;
			hscrollbar.height = thickness;
			hscrollbar.x = 0;
			hscrollbar.y = canvasheight;
			
			vscrollbar.height = canvasheight;
			vscrollbar.width = thickness;
			vscrollbar.x = canvaswidth;
			vscrollbar.y = 0;
			
			updateScrollBars();
			drawImage();
		}
		
		public function set dataProvider(data: Array): void {
			fullgeimage = data[0];
			fullmodulesimage = data[1];
			modulesOutlines = data[2];
			modulesColors = data[3];
			modulesWidth = data[4][0];
			modulesHeight = data[4][1];
			var showall:Boolean = data[5];			
			maximalWidth = fullgeimage.width;
			maximalHeight = fullgeimage.height;
			if ( modulesWidth == 0 || modulesHeight == 0 || showall ) {
				currentRectangle = new Rectangle(0, 0, maximalWidth, maximalHeight);
			} else {
				currentRectangle = new Rectangle(0, 0, modulesWidth, modulesHeight);
			}
			lastRectangle = currentRectangle.clone();
			drawImage();
		}
		
		private function alphaSliderChangeHandler(event:MenuEvent): void {
			geimage.alpha = event.data[0]
		}

		private function setHighlightingVisibilityHandler(event:MenuEvent): void {
			highlighting = event.data[0];
		}

		private function setOutlineVisibilityHandler(event:MenuEvent): void {
			modulesCanvas.visible = event.data[0];
		}

		private function setFillingVisibilityHandler(event:MenuEvent): void {
			modulesimage.visible = event.data[0];
		}

		private function highlightModulesHandler(event:HighlightingEvent): void {
			try {
				highlightCanvas.rawChildren.removeChild(highlightCanvas.rawChildren.getChildByName("modules"));
			} catch (err:Error) { 
			}
			
			highlightedModules = event.data[0];
			var shape:Shape = new Shape();			
			shape.name = "modules";
			
			for ( var module:int = 1; module < highlightedModules.length; ++module ) {
				if ( highlightedModules[module] == null ) { 
					continue;
				}

				// to draw arrow
				var arrowCommands:Vector.<int> = new Vector.<int>(8, true);
				arrowCommands[0] = 1;
				for ( var move:int = 1; move < 8; ++move ) {
					arrowCommands[move] = 2;
				}
				
				for ( var i:int = 0; i < highlightedModules[module].length; ++i ) {
					var r:Rectangle = currentRectangle.intersection(highlightedModules[module][i]);
					if ( r.width > 0 && r.height > 0 ) {
						var scalex:Number = canvaswidth / currentRectangle.width;
						var scaley:Number = canvasheight / currentRectangle.height;
						var x:Number = (r.x - currentRectangle.x) * scalex;
						var y:Number = (r.y - currentRectangle.y) * scaley;
						var dx:Number = r.width * scalex;
						var dy:Number = r.height * scaley;
						shape.alpha = 0.4;
						shape.graphics.beginFill(modulesColors[module][1]);
						shape.graphics.drawRect(x, y, dx, dy);
						shape.graphics.endFill();
						
						// draw arrows
						var h:Number = 30;
						var w:Number = h * 2/3;
					    var arrowCoordinates:Vector.<Number> = new Vector.<Number>(16, true);
					    arrowCoordinates[0] = x; arrowCoordinates[1] = y;
					    arrowCoordinates[2] = x+w/2; arrowCoordinates[3] = y-h/3;
					    arrowCoordinates[4] = x+w/4; arrowCoordinates[5] = arrowCoordinates[3];
					    arrowCoordinates[6] = arrowCoordinates[4]; arrowCoordinates[7] = y-h;
					    arrowCoordinates[8] = x-w/4; arrowCoordinates[9] = arrowCoordinates[7];
					    arrowCoordinates[10] = arrowCoordinates[8]; arrowCoordinates[11] = arrowCoordinates[3];
					    arrowCoordinates[12] = x-w/2; arrowCoordinates[13] = arrowCoordinates[3];
					    arrowCoordinates[14] = x; arrowCoordinates[15] = y;

						shape.graphics.beginFill(modulesColors[module][1]);
						shape.graphics.drawPath(arrowCommands, arrowCoordinates);
						shape.graphics.endFill();
					}
					
				}
			}
			highlightCanvas.rawChildren.addChild(shape);
		}

		private function highlightGenesHandler(event:HighlightingEvent): void {
			try {
				highlightCanvas.rawChildren.removeChild(highlightCanvas.rawChildren.getChildByName("genes"));
			} catch (err:Error) {
			}
			
			highlightedGenes = event.data[0];
			var shape:Shape = new Shape();
			shape.name = "genes";
			shape.alpha = 0.3;
						
			for ( var i:int = 0; i < highlightedGenes.length; ++i ) {
				var r:Rectangle = currentRectangle.intersection(highlightedGenes[i]);
				if ( r.width > 0 && r.height > 0 ) {
					var scalex:Number = canvaswidth / currentRectangle.width;
					var scaley:Number = canvasheight / currentRectangle.height;
					var x:Number = (r.x - currentRectangle.x) * scalex;
					var y:Number = (r.y - currentRectangle.y) * scaley;
					var dx:Number = r.width * scalex;
					var dy:Number = r.height * scaley;
					shape.graphics.beginFill(0xffff00);
					shape.graphics.drawRect(x, y, dx, dy);
					shape.graphics.endFill();
				}
			}
			highlightCanvas.rawChildren.addChild(shape);
		}
		
		private function highlightSamplesHandler(event:HighlightingEvent): void {
			try {
				highlightCanvas.rawChildren.removeChild(highlightCanvas.rawChildren.getChildByName("samples"));
			} catch (err:Error) { 
			}
			
			highlightedSamples = event.data[0];
			var shape:Shape = new Shape();
			shape.name = "samples";
			shape.alpha = 0.3;
			
			for ( var i:int = 0; i < highlightedSamples.length; ++i ) {
				var r:Rectangle = currentRectangle.intersection(highlightedSamples[i]);
				if ( r.width > 0 && r.height > 0 ) {
					var scalex:Number = canvaswidth / currentRectangle.width;
					var scaley:Number = canvasheight / currentRectangle.height;
					var x:Number = (r.x - currentRectangle.x) * scalex;
					var y:Number = (r.y - currentRectangle.y) * scaley;
					var dx:Number = r.width * scalex;
					var dy:Number = r.height * scaley;
					shape.graphics.beginFill(0xffff00);
					shape.graphics.drawRect(x, y, dx, dy);
					shape.graphics.endFill();
				}
			}
			highlightCanvas.rawChildren.addChild(shape);
		}

		public function addListener(): void {
			parentApplication.addEventListener(MenuEvent.MODE, modeChangeHandler);
		}

		public function removeListener(): void {
			parentApplication.removeEventListener(MenuEvent.MODE, modeChangeHandler);
		}


		public function getBitmap():Bitmap {
			var trans:ColorTransform = new ColorTransform();
			trans.alphaMultiplier = 1 - geimage.alpha;
			var bitmapData:BitmapData = new BitmapData(currentgeimage.width, currentgeimage.height);
			bitmapData.draw(currentgeimage);
			if ( modulesimage.visible ) {
				bitmapData.draw(currentmodulesimage, null, trans);
			}
			if ( modulesCanvas.visible ) {
				bitmapData.draw(modulesCanvas);
			}			
			return new Bitmap(bitmapData);
		}

		public function getRectangle():Rectangle {
			return currentRectangle.clone();
		}
		
	}
}	

