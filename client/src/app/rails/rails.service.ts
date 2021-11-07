import { camelCaseToSnakeCase } from '../utils/case';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { RawRailsService } from './raw-rails.service';
import { HttpVerb } from './http-verb';
import { environment } from './../../environments/environment';

class UrlParameterPath {
  path: string[];

  constructor(readonly root: string, path?: string[]) {
    this.path = path || [];
  }

  withSegment(segment: string) {
    const extendedPath: string[] = Object.assign([], this.path);
    extendedPath.push(segment);
    return new UrlParameterPath(this.root, extendedPath);
  }

  withArraySegment() {
    const extendedPath: string[] = Object.assign([], this.path);
    extendedPath.push('');
    return new UrlParameterPath(this.root, extendedPath);
  }

  key() {
    return camelCaseToSnakeCase(this.root) + this.path.map(s => `[${camelCaseToSnakeCase(s)}]`).join('');
  }

  serializeWithValue(value: any) {
    return `${encodeURIComponent(this.key())}=${encodeURIComponent(value)}`;
  }
}

@Injectable({
  providedIn: 'root',
})
export class RailsService {
  constructor(private readonly rails: RawRailsService) {}

  ajax<X>(type: HttpVerb, relativeUrl: string, data: object): Observable<X> {
    const url = environment.apiPrefix + relativeUrl;
    return new Observable<X>((observer) => {
      let subscribed = true;
      const params = this.serializeUrlParams(data);
      this.rails.ajax({
	type,
	url,
	dataType: 'json',
	data: params,
	success: (response: X) => {
	  if (subscribed) {
	    observer.next(response);
	    observer.complete();
	  }
	},
	error: (response: any, statusText: string, xhr: any) => { if (subscribed) { observer.error(xhr); } }
      });
      return {
	unsubscribe() {
	  subscribed = false;
	}
      };
    });
  }

  private serializeUrlParams(data: object) {
    const partsAccumulator: string[] = [];
    for (let [key, value] of Object.entries(data)) {
      this.serializeUrlParamsPart(value, new UrlParameterPath(key), partsAccumulator);
    }
    return partsAccumulator.join('&');
  }

  private serializeUrlParamsPart(value: any, path: UrlParameterPath, partsAccumulator: string[]) {
    if (typeof value === "object") {
      if (value instanceof Array) {
	for (let subValue of value) {
	  this.serializeUrlParamsPart(subValue, path.withArraySegment(), partsAccumulator);
	}
      } else {
	for (let [key, subValue] of Object.entries(value)) {
	  this.serializeUrlParamsPart(subValue, path.withSegment(key), partsAccumulator);
	}
      }
    } else {
      partsAccumulator.push(path.serializeWithValue(value));
    }
  }
}