/* $Id: expander.js 578 2015-09-18 14:56:34Z kate $ */

var Expander = new (function () {

	/* see http://elide.org/snippets/css.js */
	function hasclass(node, klass) {
		var a, c;

		c = node.getAttribute('class');
		if (c == null) {
			return;
		}

		a = c.split(/\s/);

		for (var i in a) {
			if (a[i] == klass) {
				return true;
			}
		}

		return false;
	}

	/* see http://elide.org/snippets/css.js */
	function removeclass(node, klass) {
		var a, c;

		c = node.getAttribute('class');
		if (c == null) {
			return;
		}

		a = c.split(/\s/);

		for (var i = 0; i < a.length; i++) {
			if (a[i] == klass || a[i] == '') {
				a.splice(i, 1);
				i--;
			}
		}

		if (a.length == 0) {
			node.removeAttribute('class');
		} else {
			node.setAttribute('class', a.join(' '));
		}
	}

	/* see http://elide.org/snippets/css.js */
	function addclass(node, klass) {
		var a, c;

		a = [ ];

		c = node.getAttribute('class');
		if (c != null) {
			a = c.split(/\s/);
		}

		for (var i = 0; i < a.length; i++) {
			if (a[i] == klass || a[i] == '') {
				a.splice(i, 1);
				i--;
			}
		}

		a.push(klass);

		node.setAttribute('class', a.join(' '));
	}

	this.toggle = function (a, accordion, expand) {
		var dl, dt;
		var endclass;
		var r;

		if (a.nodeName.toLowerCase() == 'thead') {
			dt = a;
		} else {
			dt = a.parentNode;
		}

		for (dl = dt; dl != null; dl = dl.parentNode) {
			if (hasclass(dl, "expandable")) {
				break;
			}
		}

		r = !hasclass(dt, "current");

		if (dl == null) {
			return r;
		}

		if (accordion) {
			var xdt = dl.getElementsByTagName("dt");
			for (var j = 0; j < xdt.length; j++) {
				removeclass(xdt[j], "current");
			}

			if (r) {
				addclass(dt, "current");
			}
		}

		if (expand) {
			if (hasclass(dl, "expanded")) {
				endclass = "collapsed";
			} else {
				endclass = "expanded";
			}

			removeclass(dl, "expanded");
			removeclass(dl, "collapsed");

			addclass(dl, endclass);
		}

		return r;
	}

	this.init = function (root, dlname, dtname, accordion, expand) {
		var dl = root.getElementsByTagName(dlname);

		for (var i = 0; i < dl.length; i++) {
			if (!hasclass(dl[i], "expandable")) {
				continue;
			}

			var dt = dl[i].getElementsByTagName(dtname);
			for (var j = 0; j < dt.length; j++) {
				var a;

				if (dt[j].nodeName.toLowerCase() == 'th'
				 && dt[j].parentNode.nodeName.toLowerCase() == 'tr'
				 && dt[j].parentNode.parentNode.nodeName.toLowerCase() == 'thead')
				{
					/* special case for collapsing thead/tbody within tables;
					 * use thead for onclick */
					a = dt[j].parentNode.parentNode;
				} else {

					a = dt[j].getElementsByTagName("a");
					if (a.length > 0) {
						a = a[0];
					} else {
						a = document.createElementNS('http://www.w3.org/1999/xhtml', 'a');
						a.innerHTML  = dt[j].innerHTML;

						dt[j].innerHTML = '';
						dt[j].appendChild(a);
					}
				}

				a.onclick = function () {
						return Expander.toggle(this, accordion, expand);
					};
			}

			if (!accordion && !hasclass(dl[i], "expanded")) {
				addclass(dl[i], "collapsed");
			}
		}
	}

});

