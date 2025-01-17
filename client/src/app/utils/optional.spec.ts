import { some, none, mapOptional, forceValue, hasValue, checkNone } from './optional';

describe('Optional', () => {
  it('should support mapOptional', () => {
    expect(mapOptional(some(2), x => x + 1)).toEqual(some(3));
    expect(mapOptional(none, (x: number) => x + 1)).toEqual(none);
  });

  it('should support forceValue', () => {
    expect(forceValue(some(2))).toEqual(2);
    expect(() => forceValue(none)).toThrowError();
  });

  it('should support hasValue', () => {
    expect(hasValue(some(2))).toBeTrue();
    expect(hasValue(none)).toBeFalse();
  });

  it('should support checkNone', () => {
    expect(() => checkNone(some(2))).toThrowError();
    expect(() => checkNone(none)).not.toThrowError();
  });
});
