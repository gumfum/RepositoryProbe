package net.exkazuu.probe.common

class Idioms {
	def static <T> retry(Functions.Function0<T> func, int count) {
		retry(func, count, 0, null, false, false)
	}

	def static <T> retry(Functions.Function0<T> func, int count, int sleep) {
		retry(func, count, sleep, null, false, false)
	}

	def static <T> retry(Functions.Function0<T> func, int count, int sleep, T valueWhenFailing) {
		retry(func, count, sleep, valueWhenFailing, false, false)
	}

	def static <T> retry(Functions.Function0<T> func, int count, int sleep, T valueWhenFailing, boolean verbosely) {
		retry(func, count, sleep, valueWhenFailing, verbosely, false)
	}

	def static <T> retry(Functions.Function0<T> func, int count, int sleep, T valueWhenFailing, boolean verbosely,
		boolean showingAllErrors) {
		for (i : 1 .. count) {
			try {
				return func.apply
			} catch (Exception e) {
				if (verbosely && (showingAllErrors || i == count)) {
					e.printStackTrace
				}
				if (i != count) {
					Thread.sleep(sleep)
				}
			}
		}
	}

	def static <T> retry(Functions.Function0<T> func, int count,
		Procedures.Procedure3<Exception, Integer, Integer> failHandler) {
		retry(func, count, null, failHandler)
	}

	def static <T> retry(Functions.Function0<T> func, int count, T valueWhenFailing,
		Procedures.Procedure3<Exception, Integer, Integer> failHandler) {
		for (i : 1 .. count) {
			try {
				return func.apply
			} catch (Exception e) {
				failHandler.apply(e, i, count)
			}
		}
		valueWhenFailing
	}
}
