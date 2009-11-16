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

package ch.unil.cbg.ExpressionView.events {
	
	import flash.events.Event;
	
	public class ResizeBrowserEvent extends Event {

		public var scaleX:Number;
		public var scaleY:Number;
		public static const RESIZEBROWSEREVENT:String = "ResizeBrowserEvent";
		
		public function ResizeBrowserEvent(_scaleX:Number, _scaleY:Number) {
			super(RESIZEBROWSEREVENT, true, true);
			scaleX = _scaleX;
			scaleY = _scaleY;
		}
		
		override public function clone(): Event {
			return new ResizeBrowserEvent(scaleX, scaleY);
		}

	}
}