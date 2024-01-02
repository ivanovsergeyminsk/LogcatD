{***************************************************************************************************

  Delphi Utils

  Original Author : Florian Bernd

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.

***************************************************************************************************}

unit System.AtomicTypes;

interface

uses
  System.TypInfo;

type
  {**
   * @brief Implements an atomic boolean type.
   * }
  TAtomicBoolean<T: record> = record
  strict private type
    TOrdinalType = UInt32;
    POrdinalType = ^TOrdinalType;
    PGenericType = ^T;
    PUInt8       = ^UInt8;
    PUInt16      = ^UInt16;
    PUInt32      = ^UInt32;
  strict private
    class var OrdinalMask: TOrdinalType;
  strict private
    FValue: TOrdinalType;
  strict private
    class procedure CheckGenericType; static; inline;
  strict private
    class function ToOrdinal(const Value: T): TOrdinalType; static; inline;
    class function ToGeneric(const Value: TOrdinalType): T; static; inline;
  public
    {**
     * @brief Returns the current value of the `TAtomicBoolean`.
     *
     * @return  The current value of the `TAtomicBoolean`.
     * }
    function Get: T; inline;
    {**
     * @brief Sets the value of the `TAtomicBoolean`.
     *
     * @param Value The new value.
     * }
    procedure Assign(const Value: T); inline;
    {**
     * @brief Returns the current value of the `TAtomicBoolean`. This operation is NOT ATOMIC.
     *
     * @return  The current value of the `TAtomicBoolean`.
     *
     * Use this method only, if no other thread concurrently writes the value of this
     * `TAtomicBoolean` at the same time.
     * }
    function UnsafeGet: T; inline;
    {**
     * @brief Sets the value of the `TAtomicBoolean`. This operation is NOT ATOMIC.
     *
     * @param Value The new value.
     *
     * Use this method only, if no other thread concurrently accesses (read or write) the value
     * of this `TAtomicBoolean` at the same time.
     * }
    procedure UnsafeAssign(const Value: T); inline;
  public
    {**
     * @brief Exchanges the value of the `TAtomicBoolean`.
     *
     * @param Value The new value.
     *
     * @return  The old value of this `TAtomicBoolean`.
     * }
    function Exchange(const Value: T): T; inline;
    {**
     * @brief Exchanges the value of the `TAtomicBoolean`, after comparing with the given value.
     *
     * @param Value     The new value.
     * @param Comparand The value to compare against.
     *
     * @return  The old value of this `TAtomicBoolean`.
     * }
    function CompareExchange(const Value, Comparand: T): T; inline;
  public
    class constructor Create;
  public
    {**
     * @brief Implicit cast to the generic type. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicBoolean`.
     *
     * @return  The current value of the `TAtomicBoolean`.
     * }
    class operator Implicit(const A: TAtomicBoolean<T>): T; inline;
    class operator Explicit(const A: TAtomicBoolean<T>): T; inline;
    class operator Equal(const A, B: TAtomicBoolean<T>): Boolean; inline;
    class operator Equal(const A: TAtomicBoolean<T>; const B: T): Boolean; inline;
    class operator Equal(const A: T; const B: TAtomicBoolean<T>): Boolean; inline;
    class operator NotEqual(const A, B: TAtomicBoolean<T>): Boolean; inline;
    class operator NotEqual(const A: TAtomicBoolean<T>; const B: T): Boolean; inline;
    class operator NotEqual(const A: T; const B: TAtomicBoolean<T>): Boolean; inline;
    class operator LogicalNot(const A: TAtomicBoolean<T>): T; inline;
    class operator LogicalAnd(const A, B: TAtomicBoolean<T>): T; inline;
    class operator LogicalAnd(const A: TAtomicBoolean<T>; const B: T): T; inline;
    class operator LogicalAnd(const A: T; const B: TAtomicBoolean<T>): T; inline;
    class operator LogicalOr(const A, B: TAtomicBoolean<T>): T; inline;
    class operator LogicalOr(const A: TAtomicBoolean<T>; const B: T): T; inline;
    class operator LogicalOr(const A: T; const B: TAtomicBoolean<T>): T; inline;
    class operator LogicalXor(const A, B: TAtomicBoolean<T>): T; inline;
    class operator LogicalXor(const A: TAtomicBoolean<T>; const B: T): T; inline;
    class operator LogicalXor(const A: T; const B: TAtomicBoolean<T>): T; inline;
  end;

  {**
   * @brief Implements an atomic enum type.
   * }
  TAtomicEnum<T: record> = record
  strict private type
    TOrdinalType = UInt32;
    POrdinalType = ^TOrdinalType;
    PGenericType = ^T;
  strict private
    class var OrdinalMask: TOrdinalType;
    class var EnumMinValue: T;
    class var EnumMaxValue: T;
  strict private
    FValue: TOrdinalType;
  strict private
    class procedure CheckGenericType; static; inline;
  strict private
    class function ToOrdinal(const Value: T): TOrdinalType; static; inline;
    class function ToGeneric(const Value: TOrdinalType): T; static; inline;
  public
    {**
     * @brief Returns the current value of the `TAtomicEnum`.
     *
     * @return  The current value of the `TAtomicEnum`.
     * }
    function Get: T; inline;
    {**
     * @brief Sets the value of the `TAtomicEnum`.
     *
     * @param Value The new value.
     * }
    procedure Assign(const Value: T); inline;
    {**
     * @brief Returns the current value of the `TAtomicEnum`. This operation is NOT ATOMIC.
     *
     * @return  The current value of the `TAtomicEnum`.
     *
     * Use this method only, if no other thread concurrently writes the value of this
     * `TAtomicEnum` at the same time.
     * }
    function UnsafeGet: T; inline;
    {**
     * @brief Sets the value of the `TAtomicEnum`. This operation is NOT ATOMIC.
     *
     * @param Value The new value.
     *
     * Use this method only, if no other thread concurrently accesses (read or write) the value
     * of this `TAtomicEnum` at the same time.
     * }
    procedure UnsafeAssign(const Value: T); inline;
  public
    {**
     * @brief Exchanges the value of the `TAtomicEnum`.
     *
     * @param Value The new value.
     *
     * @return  The old value of this `TAtomicEnum`.
     * }
    function Exchange(const Value: T): T; inline;
    {**
     * @brief Exchanges the value of the `TAtomicEnum`, after comparing with the given value.
     *
     * @param Value     The new value.
     * @param Comparand The value to compare against.
     *
     * @return  The old value of this `TAtomicEnum`.
     * }
    function CompareExchange(const Value, Comparand: T): T; inline;
  public
    {**
     * @brief Returns the first element of the `TAtomicEnum`.
     *
     * @return  The first element of the `TAtomicEnum`.
     * }
    class function MinValue: T; static; inline;
    {**
     * @brief Returns the last element of the `TAtomicEnum`.
     *
     * @return  The last element of the `TAtomicEnum`.
     * }
    class function MaxValue: T; static; inline;
  public
    class constructor Create;
  public
    {**
     * @brief Implicit cast to the generic type. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicEnum`.
     *
     * @return  The current value of the `TAtomicEnum`.
     * }
    class operator Implicit(const A: TAtomicEnum<T>): T; inline;
    class operator Explicit(const A: TAtomicEnum<T>): T; inline;
    class operator Equal(const A, B: TAtomicEnum<T>): Boolean; inline;
    class operator Equal(const A: TAtomicEnum<T>; const B: T): Boolean; inline;
    class operator Equal(const A: T; const B: TAtomicEnum<T>): Boolean; inline;
    class operator GreaterThan(const A, B: TAtomicEnum<T>): Boolean; inline;
    class operator GreaterThan(const A: TAtomicEnum<T>; const B: T): Boolean; inline;
    class operator GreaterThan(const A: T; const B: TAtomicEnum<T>): Boolean; inline;
    class operator GreaterThanOrEqual(const A, B: TAtomicEnum<T>): Boolean; inline;
    class operator GreaterThanOrEqual(const A: TAtomicEnum<T>; const B: T): Boolean; inline;
    class operator GreaterThanOrEqual(const A: T; const B: TAtomicEnum<T>): Boolean; inline;
    class operator LessThan(const A, B: TAtomicEnum<T>): Boolean; inline;
    class operator LessThan(const A: TAtomicEnum<T>; const B: T): Boolean; inline;
    class operator LessThan(const A: T; const B: TAtomicEnum<T>): Boolean; inline;
    class operator LessThanOrEqual(const A, B: TAtomicEnum<T>): Boolean; inline;
    class operator LessThanOrEqual(const A: TAtomicEnum<T>; const B: T): Boolean; inline;
    class operator LessThanOrEqual(const A: T; const B: TAtomicEnum<T>): Boolean; inline;
    class operator NotEqual(const A, B: TAtomicEnum<T>): Boolean; inline;
    class operator NotEqual(const A: TAtomicEnum<T>; const B: T): Boolean; inline;
    class operator NotEqual(const A: T; const B: TAtomicEnum<T>): Boolean; inline;
  end;

  {**
   * @brief Implements an atomic set type.
   * }
  TAtomicSet<T; V: record> = record
  strict private type
    TOrdinalType = Int32;
    POrdinalType = ^TOrdinalType;
    PGenericType = ^T;
    TEnumType    = UInt8;
    PEnumType    = ^TEnumType;
    TSetType     = set of 0..31;
    PSetType     = ^TSetType;
  strict private
    class var OrdinalMask: TOrdinalType;
  strict private
    FValue: TOrdinalType;
  strict private
    class procedure CheckGenericType; static; inline;
  strict private
    class function ToOrdinal(const Value: T): TOrdinalType; static; inline;
    class function ToGeneric(const Value: TOrdinalType): T; overload; static; inline;
    class function ToGeneric(const Value: TSetType): T; overload; static; inline;
  public
    {**
     * @brief Returns the current value of the `TAtomicSet`.
     *
     * @return  The current value of the `TAtomicSet`.
     * }
    function Get: T; inline;
    {**
     * @brief Sets the value of the `TAtomicSet`.
     *
     * @param Value The new value.
     * }
    procedure Assign(const Value: T); inline;
    {**
     * @brief Returns the current value of the `TAtomicSet`. This operation is NOT ATOMIC.
     *
     * @return  The current value of the `TAtomicSet`.
     *
     * Use this method only, if no other thread concurrently writes the value of this
     * `TAtomicSet` at the same time.
     * }
    function UnsafeGet: T; inline;
    {**
     * @brief Sets the value of the `TAtomicSet`. This operation is NOT ATOMIC.
     *
     * @param Value The new value.
     *
     * Use this method only, if no other thread concurrently accesses (read or write) the value
     * of this `TAtomicSet` at the same time.
     * }
    procedure UnsafeAssign(const Value: T); inline;
  public
    {**
     * @brief Exchanges the value of the `TAtomicSet`.
     *
     * @param Value The new value.
     *
     * @return  The old value of this `TAtomicSet`.
     * }
    function Exchange(const Value: T): T; inline;
    {**
     * @brief Exchanges the value of the `TAtomicSet`, after comparing with the given value.
     *
     * @param Value     The new value.
     * @param Comparand The value to compare against.
     *
     * @return  The old value of this `TAtomicSet`.
     * }
    function CompareExchange(const Value, Comparand: T): T; inline;
  public
    {**
     * @brief Includes an element to the `TAtomicSet`.
     *
     * @param Value The element to include.
     * }
    procedure Include(const Value: V); inline;
    {**
     * @brief Excludes an element from the `TAtomicSet`.
     *
     * @param Value The element to exclude.
     * }
    procedure Exclude(const Value: V); inline;
  public
    class constructor Create;
  public
    {**
     * @brief Implicit cast to the generic type. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicSet`.
     *
     * @return  The current value of the `TAtomicSet`.
     * }
    class operator Implicit(const A: TAtomicSet<T, V>): T; inline;
    class operator Explicit(const A: TAtomicSet<T, V>): T; inline;
    class operator In(const A: V; const B: TAtomicSet<T, V>): Boolean; inline;
    class operator Equal(const A, B: TAtomicSet<T, V>): Boolean; inline;
    class operator Equal(const A: TAtomicSet<T, V>; const B: T): Boolean; inline;
    class operator Equal(const A: T; const B: TAtomicSet<T, V>): Boolean; inline;
    class operator GreaterThan(const A, B: TAtomicSet<T, V>): Boolean; inline;
    class operator GreaterThan(const A: TAtomicSet<T, V>; const B: T): Boolean; inline;
    class operator GreaterThan(const A: T; const B: TAtomicSet<T, V>): Boolean; inline;
    class operator GreaterThanOrEqual(const A, B: TAtomicSet<T, V>): Boolean; inline;
    class operator GreaterThanOrEqual(const A: TAtomicSet<T, V>; const B: T): Boolean; inline;
    class operator GreaterThanOrEqual(const A: T; const B: TAtomicSet<T, V>): Boolean; inline;
    class operator LessThan(const A, B: TAtomicSet<T, V>): Boolean; inline;
    class operator LessThan(const A: TAtomicSet<T, V>; const B: T): Boolean; inline;
    class operator LessThan(const A: T; const B: TAtomicSet<T, V>): Boolean; inline;
    class operator LessThanOrEqual(const A, B: TAtomicSet<T, V>): Boolean; inline;
    class operator LessThanOrEqual(const A: TAtomicSet<T, V>; const B: T): Boolean; inline;
    class operator LessThanOrEqual(const A: T; const B: TAtomicSet<T, V>): Boolean; inline;
    class operator NotEqual(const A, B: TAtomicSet<T, V>): Boolean; inline;
    class operator NotEqual(const A: TAtomicSet<T, V>; const B: T): Boolean; inline;
    class operator NotEqual(const A: T; const B: TAtomicSet<T, V>): Boolean; inline;
    class operator Add(const A, B: TAtomicSet<T, V>): T; inline;
    class operator Add(const A: TAtomicSet<T, V>; const B: T): T; inline;
    class operator Add(const A: T; const B: TAtomicSet<T, V>): T; inline;
    class operator Subtract(const A, B: TAtomicSet<T, V>): T; inline;
    class operator Subtract(const A: TAtomicSet<T, V>; const B: T): T; inline;
    class operator Subtract(const A: T; const B: TAtomicSet<T, V>): T; inline;
  end;

  {**
   * @brief Implements an atomic integer type.
   * }
  TAtomicInteger<T: record> = record
  strict private type
    TOrdinalType = UInt32;
    POrdinalType = ^TOrdinalType;
    PGenericType = ^T;
    PUInt8       = ^UInt8;
    PUInt16      = ^UInt16;
    PUInt32      = ^UInt32;
    PUIntPtr     = ^UIntPtr;
    PInt8        = ^Int8;
    PInt16       = ^Int16;
    PInt32       = ^Int32;
    PIntPtr      = ^IntPtr;
  strict private
    class var OrdinalMask: TOrdinalType;
  strict private
    FValue: TOrdinalType;
  strict private
    class procedure CheckGenericType; static; inline;
  strict private
    class function ToOrdinal(const Value: T): TOrdinalType; static; inline;
    class function ToGeneric(const Value: TOrdinalType): T; static; inline;
  strict private
    class function Compare(const A, B: T): Integer; static; inline;
    class function GenericAdd(const A, B: T): T; static; inline;
    class function GenericSub(const A, B: T): T; static; inline;
    class function GenericMul(const A, B: T): T; static; inline;
    class function GenericDiv(const A, B: T): Double; static; inline;
    class function GenericIntDiv(const A, B: T): T; static; inline;
    class function GenericMod(const A, B: T): T; static; inline;
  strict private
    function GetOrdinal: TOrdinalType; inline;
  public
    {**
     * @brief Returns the current value of the `TAtomicInteger`.
     *
     * @return  The current value of the `TAtomicInteger`.
     * }
    function Get: T; inline;
    {**
     * @brief Sets the value of the `TAtomicInteger`.
     *
     * @param Value The new value.
     * }
    procedure Assign(const Value: T); inline;
    {**
     * @brief Returns the current value of the `TAtomicInteger`. This operation is NOT ATOMIC.
     *
     * @return  The current value of the `TAtomicInteger`.
     *
     * Use this method only, if no other thread concurrently writes the value of this
     * `TAtomicInteger` at the same time.
     * }
    function UnsafeGet: T; inline;
    {**
     * @brief Sets the value of the `TAtomicInteger`. This operation is NOT ATOMIC.
     *
     * @param Value The new value.
     *
     * Use this method only, if no other thread concurrently accesses (read or write) the value
     * of this `TAtomicInteger` at the same time.
     * }
    procedure UnsafeAssign(const Value: T); inline;
  public
    {**
     * @brief Exchanges the value of the `TAtomicInteger`.
     *
     * @param Value The new value.
     *
     * @return  The old value of this `TAtomicInteger`.
     * }
    function Exchange(const Value: T): T; inline;
    {**
     * @brief Exchanges the value of the `TAtomicInteger`, after comparing with the given value.
     *
     * @param Value     The new value.
     * @param Comparand The value to compare against.
     *
     * @return  The old value of this `TAtomicInteger`.
     * }
    function CompareExchange(const Value, Comparand: T): T; inline;
  public
    {**
     * @brief Adds to the value of the `TAtomicInteger`.
     *
     * @param Value The value to add.
     * }
    procedure Add(const Value: T); inline;
    {**
     * @brief Subtracts from the value of the `TAtomicInteger`.
     *
     * @param Value The value to subtract.
     * }
    procedure Sub(const Value: T); inline;
    {**
     * @brief Increments the value of the `TAtomicInteger` by one.
     * }
    procedure Inc; inline;
    {**
     * @brief Decrements the value of the `TAtomicInteger` by one.
     * }
    procedure Dec; inline;
  public
    class constructor Create;
  public
    {**
     * @brief Implicit cast to the generic type. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicInteger`.
     *
     * @return  The current value of the `TAtomicInteger`.
     * }
    class operator Implicit(const A: TAtomicInteger<T>): T; inline;
    {**
     * @brief Implicit cast to `single`. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicInteger`.
     *
     * @return  The current value of the `TAtomicInteger`.
     * }
    class operator Implicit(const A: TAtomicInteger<T>): Single; inline;
    {**
     * @brief Implicit cast to `double`. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicInteger`.
     *
     * @return  The current value of the `TAtomicInteger`.
     * }
    class operator Implicit(const A: TAtomicInteger<T>): Double; inline;
    class operator Explicit(const A: TAtomicInteger<T>): T; inline;
    class operator Explicit(const A: TAtomicInteger<T>): Single; inline;
    class operator Explicit(const A: TAtomicInteger<T>): Double; inline;
    class operator Equal(const A, B: TAtomicInteger<T>): Boolean; inline;
    class operator Equal(const A: TAtomicInteger<T>; const B: T): Boolean; inline;
    class operator Equal(const A: T; const B: TAtomicInteger<T>): Boolean; inline;
    class operator GreaterThan(const A, B: TAtomicInteger<T>): Boolean; inline;
    class operator GreaterThan(const A: TAtomicInteger<T>; const B: T): Boolean; inline;
    class operator GreaterThan(const A: T; const B: TAtomicInteger<T>): Boolean; inline;
    class operator GreaterThanOrEqual(const A, B: TAtomicInteger<T>): Boolean; inline;
    class operator GreaterThanOrEqual(const A: TAtomicInteger<T>; const B: T): Boolean; inline;
    class operator GreaterThanOrEqual(const A: T; const B: TAtomicInteger<T>): Boolean; inline;
    class operator LessThan(const A, B: TAtomicInteger<T>): Boolean; inline;
    class operator LessThan(const A: TAtomicInteger<T>; const B: T): Boolean; inline;
    class operator LessThan(const A: T; const B: TAtomicInteger<T>): Boolean; inline;
    class operator LessThanOrEqual(const A, B: TAtomicInteger<T>): Boolean; inline;
    class operator LessThanOrEqual(const A: TAtomicInteger<T>; const B: T): Boolean; inline;
    class operator LessThanOrEqual(const A: T; const B: TAtomicInteger<T>): Boolean; inline;
    class operator NotEqual(const A, B: TAtomicInteger<T>): Boolean; inline;
    class operator NotEqual(const A: TAtomicInteger<T>; const B: T): Boolean; inline;
    class operator NotEqual(const A: T; const B: TAtomicInteger<T>): Boolean; inline;
    class operator Negative(const A: TAtomicInteger<T>): T; inline;
    class operator Positive(const A: TAtomicInteger<T>): T; inline;
    class operator Add(const A, B: TAtomicInteger<T>): T; inline;
    class operator Add(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator Add(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator Subtract(const A, B: TAtomicInteger<T>): T; inline;
    class operator Subtract(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator Subtract(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator Multiply(const A, B: TAtomicInteger<T>): T; inline;
    class operator Multiply(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator Multiply(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator Divide(const A, B: TAtomicInteger<T>): Double; inline;
    class operator Divide(const A: TAtomicInteger<T>; const B: T): Double; inline;
    class operator Divide(const A: T; const B: TAtomicInteger<T>): Double; inline;
    class operator IntDivide(const A, B: TAtomicInteger<T>): T; inline;
    class operator IntDivide(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator IntDivide(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator Modulus(const A, B: TAtomicInteger<T>): T; inline;
    class operator Modulus(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator Modulus(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator LeftShift(const A, B: TAtomicInteger<T>): T; inline;
    class operator LeftShift(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator LeftShift(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator RightShift(const A, B: TAtomicInteger<T>): T; inline;
    class operator RightShift(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator RightShift(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator BitwiseAnd(const A, B: TAtomicInteger<T>): T; inline;
    class operator BitwiseAnd(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator BitwiseAnd(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator BitwiseOr(const A, B: TAtomicInteger<T>): T; inline;
    class operator BitwiseOr(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator BitwiseOr(const A: T; const B: TAtomicInteger<T>): T; inline;
    class operator BitwiseXor(const A, B: TAtomicInteger<T>): T; inline;
    class operator BitwiseXor(const A: TAtomicInteger<T>; const B: T): T; inline;
    class operator BitwiseXor(const A: T; const B: TAtomicInteger<T>): T; inline;
  end;

  {**
   * @brief Implements an atomic 64-bit integer type.
   * }
  TAtomicInteger64<T: record> = record
  strict private type
    TOrdinalType = UInt64;
    POrdinalType = ^TOrdinalType;
    PGenericType = ^T;
    PUInt64      = ^UInt64;
    PUIntPtr     = ^UIntPtr;
    PInt64       = ^Int64;
    PIntPtr      = ^IntPtr;
  strict private
    FValue: TOrdinalType;
  strict private
    class procedure CheckGenericType; static; inline;
  strict private
    class function ToOrdinal(const Value: T): TOrdinalType; static; inline;
    class function ToGeneric(const Value: TOrdinalType): T; static; inline;
  strict private
    class function Compare(const A, B: T): Integer; static; inline;
    class function GenericAdd(const A, B: T): T; static; inline;
    class function GenericSub(const A, B: T): T; static; inline;
    class function GenericMul(const A, B: T): T; static; inline;
    class function GenericDiv(const A, B: T): Double; static; inline;
    class function GenericIntDiv(const A, B: T): T; static; inline;
    class function GenericMod(const A, B: T): T; static; inline;
  strict private
    function GetOrdinal: TOrdinalType; inline;
  public
    {**
     * @brief Returns the current value of the `TAtomicInteger64`.
     *
     * @return  The current value of the `TAtomicInteger64`.
     * }
    function Get: T; inline;
    {**
     * @brief Sets the value of the `TAtomicInteger64`.
     *
     * @param Value The new value.
     * }
    procedure Assign(const Value: T); inline;
    {**
     * @brief Returns the current value of the `TAtomicInteger64`. This operation is NOT ATOMIC.
     *
     * @return  The current value of the `TAtomicInteger64`.
     *
     * Use this method only, if no other thread concurrently writes the value of this
     * `TAtomicInteger64` at the same time.
     * }
    function UnsafeGet: T; inline;
    {**
     * @brief Sets the value of the `TAtomicInteger64`. This operation is NOT ATOMIC.
     *
     * @param Value The new value.
     *
     * Use this method only, if no other thread concurrently accesses (read or write) the value
     * of this `TAtomicInteger64` at the same time.
     * }
    procedure UnsafeAssign(const Value: T); inline;
  public
    {**
     * @brief Exchanges the value of the `TAtomicInteger64`.
     *
     * @param Value The new value.
     *
     * @return  The old value of this `TAtomicInteger64`.
     * }
    function Exchange(const Value: T): T; inline;
    {**
     * @brief Exchanges the value of the `TAtomicInteger64`, after comparing with the given value.
     *
     * @param Value     The new value.
     * @param Comparand The value to compare against.
     *
     * @return  The old value of this `TAtomicInteger64`.
     * }
    function CompareExchange(const Value, Comparand: T): T; inline;
  public
    {**
     * @brief Adds to the value of the `TAtomicInteger64`.
     *
     * @param Value The value to add.
     * }
    procedure Add(const Value: T); inline;
    {**
     * @brief Subtracts from the value of the `TAtomicInteger64`.
     *
     * @param Value The value to subtract.
     * }
    procedure Sub(const Value: T); inline;
    {**
     * @brief Increments the value of the `TAtomicInteger64` by one.
     * }
    procedure Inc; inline;
    {**
     * @brief Decrements the value of the `TAtomicInteger64` by one.
     * }
    procedure Dec; inline;
  public
    class constructor Create;
  public
    {**
     * @brief Implicit cast to the generic type. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicInteger64`.
     *
     * @return  The current value of the `TAtomicInteger64`.
     * }
    class operator Implicit(const A: TAtomicInteger64<T>): T; inline;
    {**
     * @brief Implicit cast to `single`. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicInteger64`.
     *
     * @return  The current value of the `TAtomicInteger64`.
     * }
    class operator Implicit(const A: TAtomicInteger64<T>): Single; inline;
    {**
     * @brief Implicit cast to `double`. This operation performs an ATOMIC read.
     *
     * @param A The `TAtomicInteger64`.
     *
     * @return  The current value of the `TAtomicInteger64`.
     * }
    class operator Implicit(const A: TAtomicInteger64<T>): Double; inline;
    class operator Explicit(const A: TAtomicInteger64<T>): T; inline;
    class operator Explicit(const A: TAtomicInteger64<T>): Single; inline;
    class operator Explicit(const A: TAtomicInteger64<T>): Double; inline;
    class operator Equal(const A, B: TAtomicInteger64<T>): Boolean; inline;
    class operator Equal(const A: TAtomicInteger64<T>; const B: T): Boolean; inline;
    class operator Equal(const A: T; const B: TAtomicInteger64<T>): Boolean; inline;
    class operator GreaterThan(const A, B: TAtomicInteger64<T>): Boolean; inline;
    class operator GreaterThan(const A: TAtomicInteger64<T>; const B: T): Boolean; inline;
    class operator GreaterThan(const A: T; const B: TAtomicInteger64<T>): Boolean; inline;
    class operator GreaterThanOrEqual(const A, B: TAtomicInteger64<T>): Boolean; inline;
    class operator GreaterThanOrEqual(const A: TAtomicInteger64<T>; const B: T): Boolean; inline;
    class operator GreaterThanOrEqual(const A: T; const B: TAtomicInteger64<T>): Boolean; inline;
    class operator LessThan(const A, B: TAtomicInteger64<T>): Boolean; inline;
    class operator LessThan(const A: TAtomicInteger64<T>; const B: T): Boolean; inline;
    class operator LessThan(const A: T; const B: TAtomicInteger64<T>): Boolean; inline;
    class operator LessThanOrEqual(const A, B: TAtomicInteger64<T>): Boolean; inline;
    class operator LessThanOrEqual(const A: TAtomicInteger64<T>; const B: T): Boolean; inline;
    class operator LessThanOrEqual(const A: T; const B: TAtomicInteger64<T>): Boolean; inline;
    class operator NotEqual(const A, B: TAtomicInteger64<T>): Boolean; inline;
    class operator NotEqual(const A: TAtomicInteger64<T>; const B: T): Boolean; inline;
    class operator NotEqual(const A: T; const B: TAtomicInteger64<T>): Boolean; inline;
    class operator Negative(const A: TAtomicInteger64<T>): T; inline;
    class operator Positive(const A: TAtomicInteger64<T>): T; inline;
    class operator Add(const A, B: TAtomicInteger64<T>): T; inline;
    class operator Add(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator Add(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator Subtract(const A, B: TAtomicInteger64<T>): T; inline;
    class operator Subtract(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator Subtract(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator Multiply(const A, B: TAtomicInteger64<T>): T; inline;
    class operator Multiply(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator Multiply(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator Divide(const A, B: TAtomicInteger64<T>): Double; inline;
    class operator Divide(const A: TAtomicInteger64<T>; const B: T): Double; inline;
    class operator Divide(const A: T; const B: TAtomicInteger64<T>): Double; inline;
    class operator IntDivide(const A, B: TAtomicInteger64<T>): T; inline;
    class operator IntDivide(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator IntDivide(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator Modulus(const A, B: TAtomicInteger64<T>): T; inline;
    class operator Modulus(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator Modulus(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator LeftShift(const A, B: TAtomicInteger64<T>): T; inline;
    class operator LeftShift(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator LeftShift(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator RightShift(const A, B: TAtomicInteger64<T>): T; inline;
    class operator RightShift(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator RightShift(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator BitwiseAnd(const A, B: TAtomicInteger64<T>): T; inline;
    class operator BitwiseAnd(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator BitwiseAnd(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator BitwiseOr(const A, B: TAtomicInteger64<T>): T; inline;
    class operator BitwiseOr(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator BitwiseOr(const A: T; const B: TAtomicInteger64<T>): T; inline;
    class operator BitwiseXor(const A, B: TAtomicInteger64<T>): T; inline;
    class operator BitwiseXor(const A: TAtomicInteger64<T>; const B: T): T; inline;
    class operator BitwiseXor(const A: T; const B: TAtomicInteger64<T>): T; inline;
  end;

  {**
   * @brief Implements an atomic single type.
   * }
  TAtomicSingle = record

  end;

  {**
   * @brief Implements an atomic double type.
   * }
  TAtomicDouble = record

  end;

  TAtomicBoolean = TAtomicBoolean<Boolean>;
  TAtomicUInt8   = TAtomicInteger<UInt8>;
  TAtomicUInt16  = TAtomicInteger<UInt16>;
  TAtomicUInt32  = TAtomicInteger<UInt32>;
  TAtomicUInt64  = TAtomicInteger64<UInt64>;
  TAtomicInt8    = TAtomicInteger<Int8>;
  TAtomicInt16   = TAtomicInteger<Int16>;
  TAtomicInt32   = TAtomicInteger<Int32>;
  TAtomicInt64   = TAtomicInteger64<Int64>;
{$IF defined(CPUX64) or defined(CPU64BITS)}
  TAtomicUIntPtr = TAtomicInteger64<UIntPtr>;
  TAtomicIntPtr  = TAtomicInteger64<IntPtr>;
{$ELSE}
  TAtomicUIntPtr = TAtomicInteger<UIntPtr>;
  TAtomicIntPtr  = TAtomicInteger<IntPtr>;
{$ENDIF}

implementation

uses
  System.SyncObjs;

{$REGION 'Class: TAtomicBoolean<T>'}
class procedure TAtomicBoolean<T>.CheckGenericType;
begin
  Assert(PTypeInfo(TypeInfo(T))^.Kind in [tkEnumeration],
    'Unsupported generic type.');
  Assert(SizeOf(T) <= SizeOf(TOrdinalType),
    'The generic type exceeded the maximum of 4 bytes.');
end;

class function TAtomicBoolean<T>.ToOrdinal(const Value: T): TOrdinalType;
begin
  Result := POrdinalType(@Value)^;
end;

class function TAtomicBoolean<T>.ToGeneric(const Value: TOrdinalType): T;
begin
  Result := PGenericType(@Value)^;
end;

function TAtomicBoolean<T>.Get: T;
begin
  Result := ToGeneric(FValue);
end;

procedure TAtomicBoolean<T>.Assign(const Value: T);
begin
  if TypeInfo(T) = TypeInfo(Boolean ) then AtomicExchange(FValue, PUInt8 (@Value)^) else
  if TypeInfo(T) = TypeInfo(ByteBool) then AtomicExchange(FValue, PUInt8 (@Value)^) else
  if TypeInfo(T) = TypeInfo(WordBool) then AtomicExchange(FValue, PUInt16(@Value)^) else
  if TypeInfo(T) = TypeInfo(LongBool) then AtomicExchange(FValue, PUInt32(@Value)^) else
  begin
    AtomicExchange(FValue, ToOrdinal(Value) and OrdinalMask);
  end;
end;

function TAtomicBoolean<T>.UnsafeGet: T;
begin
  Result := Get;
end;

procedure TAtomicBoolean<T>.UnsafeAssign(const Value: T);
begin
  if TypeInfo(T) = TypeInfo(Boolean ) then FValue := PUInt8 (@Value)^ else
  if TypeInfo(T) = TypeInfo(ByteBool) then FValue := PUInt8 (@Value)^ else
  if TypeInfo(T) = TypeInfo(WordBool) then FValue := PUInt16(@Value)^ else
  if TypeInfo(T) = TypeInfo(LongBool) then FValue := PUInt32(@Value)^ else
  begin
    FValue := ToOrdinal(Value) and OrdinalMask;
  end;
end;

function TAtomicBoolean<T>.Exchange(const Value: T): T;
begin
  Result := ToGeneric(AtomicExchange(FValue, ToOrdinal(Value)));
end;

function TAtomicBoolean<T>.CompareExchange(const Value, Comparand: T): T;
begin
  Result := ToGeneric(AtomicCmpExchange(FValue, ToOrdinal(Value), ToOrdinal(Comparand)));
end;

class constructor TAtomicBoolean<T>.Create;
begin
  CheckGenericType;
  OrdinalMask := (TOrdinalType(-1) shr ((SizeOf(TOrdinalType) - SizeOf(T)) * 8));
end;

class operator TAtomicBoolean<T>.Implicit(const A: TAtomicBoolean<T>): T;
begin
  Result := A.Get;
end;

class operator TAtomicBoolean<T>.Explicit(const A: TAtomicBoolean<T>): T;
begin
  Result := A;
end;

class operator TAtomicBoolean<T>.Equal(const A, B: TAtomicBoolean<T>): Boolean;
begin
  Result := (A.FValue = B.FValue);
end;

class operator TAtomicBoolean<T>.Equal(const A: TAtomicBoolean<T>; const B: T): Boolean;
begin
  Result := (A.FValue = ToOrdinal(B));
end;

class operator TAtomicBoolean<T>.Equal(const A: T; const B: TAtomicBoolean<T>): Boolean;
begin
  Result := (ToOrdinal(A) = B.FValue);
end;

class operator TAtomicBoolean<T>.NotEqual(const A, B: TAtomicBoolean<T>): Boolean;
begin
  Result := (A.FValue <> B.FValue);
end;

class operator TAtomicBoolean<T>.NotEqual(const A: TAtomicBoolean<T>; const B: T): Boolean;
begin
  Result := (A.FValue <> ToOrdinal(B));
end;

class operator TAtomicBoolean<T>.NotEqual(const A: T; const B: TAtomicBoolean<T>): Boolean;
begin
  Result := (ToOrdinal(A) <> B.FValue);
end;

class operator TAtomicBoolean<T>.LogicalNot(const A: TAtomicBoolean<T>): T;
begin
  Result := (A.FValue = 0);
end;

class operator TAtomicBoolean<T>.LogicalAnd(const A, B: TAtomicBoolean<T>): T;
begin
  Result := (A.FValue <> 0) and (B.FValue <> 0);
end;

class operator TAtomicBoolean<T>.LogicalAnd(const A: TAtomicBoolean<T>; const B: T): T;
begin
  Result := (A.FValue <> 0) and (ToOrdinal(B) <> 0);
end;

class operator TAtomicBoolean<T>.LogicalAnd(const A: T; const B: TAtomicBoolean<T>): T;
begin
  Result := (ToOrdinal(A) <> 0) and (B.FValue <> 0);
end;

class operator TAtomicBoolean<T>.LogicalOr(const A, B: TAtomicBoolean<T>): T;
begin
  Result := (A.FValue <> 0) or (B.FValue <> 0);
end;

class operator TAtomicBoolean<T>.LogicalOr(const A: TAtomicBoolean<T>; const B: T): T;
begin
  Result := (A.FValue <> 0) or (ToOrdinal(B) <> 0);
end;

class operator TAtomicBoolean<T>.LogicalOr(const A: T; const B: TAtomicBoolean<T>): T;
begin
  Result := (ToOrdinal(A) <> 0) or (B.FValue <> 0);
end;

class operator TAtomicBoolean<T>.LogicalXor(const A, B: TAtomicBoolean<T>): T;
begin
  Result := (A.FValue <> 0) xor (B.FValue <> 0);
end;

class operator TAtomicBoolean<T>.LogicalXor(const A: TAtomicBoolean<T>; const B: T): T;
begin
  Result := (A.FValue <> 0) xor (ToOrdinal(B) <> 0);
end;

class operator TAtomicBoolean<T>.LogicalXor(const A: T; const B: TAtomicBoolean<T>): T;
begin
  Result := (ToOrdinal(A) <> 0) xor (B.FValue <> 0);
end;
{$ENDREGION}

{$REGION 'Class: TAtomicEnum<T>'}
class procedure TAtomicEnum<T>.CheckGenericType;
begin
  Assert(PTypeInfo(TypeInfo(T))^.Kind in [tkEnumeration],
    'Unsupported generic type.');
  Assert(SizeOf(T) <= 4,
    'The generic type exceeded the maximum of 4 bytes.');
end;

class function TAtomicEnum<T>.ToOrdinal(const Value: T): TOrdinalType;
begin
  Result := POrdinalType(@Value)^;
end;

class function TAtomicEnum<T>.ToGeneric(const Value: TOrdinalType): T;
begin
  Result := PGenericType(@Value)^;
end;

function TAtomicEnum<T>.Get: T;
begin
  Result := ToGeneric(FValue);
end;

procedure TAtomicEnum<T>.Assign(const Value: T);
begin
  AtomicExchange(FValue, ToOrdinal(Value) and OrdinalMask);
end;

function TAtomicEnum<T>.UnsafeGet: T;
begin
  Result := Get;
end;

procedure TAtomicEnum<T>.UnsafeAssign(const Value: T);
begin
  FValue := ToOrdinal(Value) and OrdinalMask;
end;

function TAtomicEnum<T>.Exchange(const Value: T): T;
begin
  Result := ToGeneric(AtomicExchange(FValue, ToOrdinal(Value)));
end;

function TAtomicEnum<T>.CompareExchange(const Value, Comparand: T): T;
begin
  Result := ToGeneric(AtomicCmpExchange(FValue, ToOrdinal(Value), ToOrdinal(Comparand)));
end;

class function TAtomicEnum<T>.MinValue: T;
begin
  Result := EnumMinValue;
end;

class function TAtomicEnum<T>.MaxValue: T;
begin
  Result := EnumMaxValue;
end;

class constructor TAtomicEnum<T>.Create;
begin
  CheckGenericType;
  OrdinalMask := (TOrdinalType(-1) shr ((SizeOf(TOrdinalType) - SizeOf(T)) * 8));
  EnumMinValue := ToGeneric(PTypeInfo(TypeInfo(T))^.TypeData^.MinValue);
  EnumMaxValue := ToGeneric(PTypeInfo(TypeInfo(T))^.TypeData^.MaxValue);
end;

class operator TAtomicEnum<T>.Implicit(const A: TAtomicEnum<T>): T;
begin
  Result := ToGeneric(A.FValue);
end;

class operator TAtomicEnum<T>.Explicit(const A: TAtomicEnum<T>): T;
begin
  Result := A;
end;

class operator TAtomicEnum<T>.Equal(const A, B: TAtomicEnum<T>): Boolean;
begin
  Result := (A.FValue = B.FValue);
end;

class operator TAtomicEnum<T>.Equal(const A: TAtomicEnum<T>; const B: T): Boolean;
begin
  Result := (A.FValue = ToOrdinal(B));
end;

class operator TAtomicEnum<T>.Equal(const A: T; const B: TAtomicEnum<T>): Boolean;
begin
  Result := (ToOrdinal(A) = B.FValue);
end;

class operator TAtomicEnum<T>.GreaterThan(const A, B: TAtomicEnum<T>): Boolean;
begin
  Result := (A.FValue > B.FValue);
end;

class operator TAtomicEnum<T>.GreaterThan(const A: TAtomicEnum<T>; const B: T): Boolean;
begin
  Result := (A.FValue > ToOrdinal(B));
end;

class operator TAtomicEnum<T>.GreaterThan(const A: T; const B: TAtomicEnum<T>): Boolean;
begin
  Result := (ToOrdinal(A) > B.FValue);
end;

class operator TAtomicEnum<T>.GreaterThanOrEqual(const A, B: TAtomicEnum<T>): Boolean;
begin
  Result := (A.FValue >= B.FValue);
end;

class operator TAtomicEnum<T>.GreaterThanOrEqual(const A: TAtomicEnum<T>; const B: T): Boolean;
begin
  Result := (A.FValue >= ToOrdinal(B));
end;

class operator TAtomicEnum<T>.GreaterThanOrEqual(const A: T; const B: TAtomicEnum<T>): Boolean;
begin
  Result := (ToOrdinal(A) >= B.FValue);
end;

class operator TAtomicEnum<T>.LessThan(const A, B: TAtomicEnum<T>): Boolean;
begin
  Result := (A.FValue < B.FValue);
end;

class operator TAtomicEnum<T>.LessThan(const A: TAtomicEnum<T>; const B: T): Boolean;
begin
  Result := (A.FValue < ToOrdinal(B));
end;

class operator TAtomicEnum<T>.LessThan(const A: T; const B: TAtomicEnum<T>): Boolean;
begin
  Result := (ToOrdinal(A) < B.FValue);
end;

class operator TAtomicEnum<T>.LessThanOrEqual(const A, B: TAtomicEnum<T>): Boolean;
begin
  Result := (A.FValue <= B.FValue);
end;

class operator TAtomicEnum<T>.LessThanOrEqual(const A: TAtomicEnum<T>; const B: T): Boolean;
begin
  Result := (A.FValue <= ToOrdinal(B));
end;

class operator TAtomicEnum<T>.LessThanOrEqual(const A: T; const B: TAtomicEnum<T>): Boolean;
begin
  Result := (ToOrdinal(A) <= B.FValue);
end;

class operator TAtomicEnum<T>.NotEqual(const A, B: TAtomicEnum<T>): Boolean;
begin
  Result := (A.FValue <> B.FValue);
end;

class operator TAtomicEnum<T>.NotEqual(const A: TAtomicEnum<T>; const B: T): Boolean;
begin
  Result := (A.FValue <> ToOrdinal(B));
end;

class operator TAtomicEnum<T>.NotEqual(const A: T; const B: TAtomicEnum<T>): Boolean;
begin
  Result := (ToOrdinal(A) <> B.FValue);
end;
{$ENDREGION}

{$REGION 'Class: TAtomicSet<T, V>'}
class procedure TAtomicSet<T, V>.CheckGenericType;
begin
  Assert(PTypeInfo(TypeInfo(T))^.Kind in [tkSet],
    'Unsupported generic set type.');
  Assert(SizeOf(T) <= 4,
    'The generic set type exceeded the maximum of 4 bytes.');
  Assert(PTypeInfo(TypeInfo(V)) = PTypeInfo(TypeInfo(T))^.TypeData^.CompType^,
    'Mismatching enum type');
  Assert(PTypeInfo(TypeInfo(V))^.Kind in [tkEnumeration],
    'Unsupported generic enum type.');
  Assert(
    (PTypeInfo(TypeInfo(V))^.TypeData^.MinValue =  0) and
    (PTypeInfo(TypeInfo(V))^.TypeData^.MaxValue < 32),
    'The generic enum type exceeded the maximum of 32 elements');
end;

class function TAtomicSet<T, V>.ToOrdinal(const Value: T): TOrdinalType;
begin
  Result := POrdinalType(@Value)^;
end;

class function TAtomicSet<T, V>.ToGeneric(const Value: TOrdinalType): T;
begin
  Result := PGenericType(@Value)^;
end;

class function TAtomicSet<T, V>.ToGeneric(const Value: TSetType): T;
begin
  Result := PGenericType(@Value)^;
end;

function TAtomicSet<T, V>.Get: T;
begin
  Result := ToGeneric(FValue);
end;

procedure TAtomicSet<T, V>.Assign(const Value: T);
begin
  AtomicExchange(FValue, ToOrdinal(Value) and OrdinalMask);
end;

function TAtomicSet<T, V>.UnsafeGet: T;
begin
  Result := Get;
end;

procedure TAtomicSet<T, V>.UnsafeAssign(const Value: T);
begin
  FValue := ToOrdinal(Value) and OrdinalMask;
end;

function TAtomicSet<T, V>.Exchange(const Value: T): T;
begin
  Result := ToGeneric(AtomicExchange(FValue, ToOrdinal(Value)));
end;

function TAtomicSet<T, V>.CompareExchange(const Value, Comparand: T): T;
begin
  Result := ToGeneric(AtomicCmpExchange(FValue, ToOrdinal(Value), ToOrdinal(Comparand)));
end;

procedure TAtomicSet<T, V>.Include(const Value: V);
begin
  TInterlocked.BitTestAndSet(FValue, PEnumType(@Value)^);
end;

procedure TAtomicSet<T, V>.Exclude(const Value: V);
begin
  TInterlocked.BitTestAndClear(FValue, PEnumType(@Value)^);
end;

class constructor TAtomicSet<T, V>.Create;
begin
  CheckGenericType;
  OrdinalMask := (TOrdinalType(-1) shr ((SizeOf(TOrdinalType) - SizeOf(T)) * 8));
end;

class operator TAtomicSet<T, V>.Implicit(const A: TAtomicSet<T, V>): T;
begin
  Result := ToGeneric(A.FValue);
end;

class operator TAtomicSet<T, V>.Explicit(const A: TAtomicSet<T, V>): T;
begin
  Result := A;
end;

class operator TAtomicSet<T, V>.In(const A: V; const B: TAtomicSet<T, V>): Boolean;
begin
  Result := PEnumType(@A)^ in PSetType(@B.FValue)^;
end;

class operator TAtomicSet<T, V>.Equal(const A, B: TAtomicSet<T, V>): Boolean;
begin
  Result := (A.FValue = B.FValue);
end;

class operator TAtomicSet<T, V>.Equal(const A: TAtomicSet<T, V>; const B: T): Boolean;
begin
  Result := (A.FValue = ToOrdinal(B) and OrdinalMask);
end;

class operator TAtomicSet<T, V>.Equal(const A: T; const B: TAtomicSet<T, V>): Boolean;
begin
  Result := (ToOrdinal(A) and OrdinalMask = B.FValue);
end;

class operator TAtomicSet<T, V>.GreaterThan(const A, B: TAtomicSet<T, V>): Boolean;
begin
  Result := (A.FValue > B.FValue);
end;

class operator TAtomicSet<T, V>.GreaterThan(const A: TAtomicSet<T, V>; const B: T): Boolean;
begin
  Result := (A.FValue > ToOrdinal(B) and OrdinalMask);
end;

class operator TAtomicSet<T, V>.GreaterThan(const A: T; const B: TAtomicSet<T, V>): Boolean;
begin
  Result := (ToOrdinal(A) and OrdinalMask > B.FValue);
end;

class operator TAtomicSet<T, V>.GreaterThanOrEqual(const A, B: TAtomicSet<T, V>): Boolean;
begin
  Result := (A.FValue >= B.FValue);
end;

class operator TAtomicSet<T, V>.GreaterThanOrEqual(const A: TAtomicSet<T, V>; const B: T): Boolean;
begin
  Result := (A.FValue >= ToOrdinal(B) and OrdinalMask);
end;

class operator TAtomicSet<T, V>.GreaterThanOrEqual(const A: T; const B: TAtomicSet<T, V>): Boolean;
begin
  Result := (ToOrdinal(A) and OrdinalMask >= B.FValue);
end;

class operator TAtomicSet<T, V>.LessThan(const A, B: TAtomicSet<T, V>): Boolean;
begin
  Result := (A.FValue < B.FValue);
end;

class operator TAtomicSet<T, V>.LessThan(const A: TAtomicSet<T, V>; const B: T): Boolean;
begin
  Result := (A.FValue < ToOrdinal(B) and OrdinalMask);
end;

class operator TAtomicSet<T, V>.LessThan(const A: T; const B: TAtomicSet<T, V>): Boolean;
begin
  Result := (ToOrdinal(A) and OrdinalMask < B.FValue);
end;

class operator TAtomicSet<T, V>.LessThanOrEqual(const A, B: TAtomicSet<T, V>): Boolean;
begin
  Result := (A.FValue <= B.FValue);
end;

class operator TAtomicSet<T, V>.LessThanOrEqual(const A: TAtomicSet<T, V>; const B: T): Boolean;
begin
  Result := (A.FValue <= ToOrdinal(B) and OrdinalMask);
end;

class operator TAtomicSet<T, V>.LessThanOrEqual(const A: T; const B: TAtomicSet<T, V>): Boolean;
begin
  Result := (ToOrdinal(A) and OrdinalMask <= B.FValue);
end;

class operator TAtomicSet<T, V>.NotEqual(const A, B: TAtomicSet<T, V>): Boolean;
begin
  Result := (A.FValue <> B.FValue);
end;

class operator TAtomicSet<T, V>.NotEqual(const A: TAtomicSet<T, V>; const B: T): Boolean;
begin
  Result := (A.FValue <> ToOrdinal(B) and OrdinalMask);
end;

class operator TAtomicSet<T, V>.NotEqual(const A: T; const B: TAtomicSet<T, V>): Boolean;
begin
  Result := (ToOrdinal(A) and OrdinalMask <> B.FValue);
end;

class operator TAtomicSet<T, V>.Add(const A, B: TAtomicSet<T, V>): T;
begin
  Result := ToGeneric(PSetType(@A.FValue)^ + PSetType(@B.FValue)^);
end;

class operator TAtomicSet<T, V>.Add(const A: TAtomicSet<T, V>; const B: T): T;
begin
  Result := ToGeneric(PSetType(@A.FValue)^ + PSetType(@B)^);
end;

class operator TAtomicSet<T, V>.Add(const A: T; const B: TAtomicSet<T, V>): T;
begin
  Result := ToGeneric(PSetType(@A)^ + PSetType(@B.FValue)^);
end;

class operator TAtomicSet<T, V>.Subtract(const A, B: TAtomicSet<T, V>): T;
begin
  Result := ToGeneric(PSetType(@A.FValue)^ - PSetType(@B.FValue)^);
end;

class operator TAtomicSet<T, V>.Subtract(const A: TAtomicSet<T, V>; const B: T): T;
begin
  Result := ToGeneric(PSetType(@A.FValue)^ - PSetType(@B)^)
end;

class operator TAtomicSet<T, V>.Subtract(const A: T; const B: TAtomicSet<T, V>): T;
begin
  Result := ToGeneric(PSetType(@A)^ - PSetType(@B.FValue)^);
end;
{$ENDREGION}

{$REGION 'Class: TAtomicInteger<T> '}
class procedure TAtomicInteger<T>.CheckGenericType;
begin
  Assert(PTypeInfo(TypeInfo(T))^.Kind in [tkInteger],
    'Unsupported generic type.');
  Assert(SizeOf(T) <= 4,
    'The generic type exceeded the maximum of 4 bytes.');
end;

class function TAtomicInteger<T>.ToGeneric(const Value: TOrdinalType): T;
begin
  Result := PGenericType(@Value)^;
end;

class function TAtomicInteger<T>.ToOrdinal(const Value: T): TOrdinalType;
begin
  Result := POrdinalType(@Value)^;
end;

class function TAtomicInteger<T>.Compare(const A, B: T): Integer;
begin
  Result := 0;
  if TypeInfo(T) = TypeInfo(UInt8) then
  begin
    if (PUInt8(@A)^   > PUInt8(@B)^)   then Result :=  1 else
    if (PUInt8(@A)^   < PUInt8(@B)^)   then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(UInt16) then
  begin
    if (PUInt16(@A)^  > PUInt16(@B)^)  then Result :=  1 else
    if (PUInt16(@A)^  < PUInt16(@B)^)  then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(UInt32) then
  begin
    if (PUInt32(@A)^  > PUInt32(@B)^)  then Result :=  1 else
    if (PUInt32(@A)^  < PUInt32(@B)^)  then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(UIntPtr) then
  begin
    if (PUIntPtr(@A)^ > PUIntPtr(@B)^) then Result :=  1 else
    if (PUIntPtr(@A)^ < PUIntPtr(@B)^) then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(Int8) then
  begin
    if (PInt8(@A)^    > PInt8(@B)^)    then Result :=  1 else
    if (PInt8(@A)^    < PInt8(@B)^)    then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(Int16) then
  begin
    if (PInt16(@A)^   > PInt16(@B)^)   then Result :=  1 else
    if (PInt16(@A)^   < PInt16(@B)^)   then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(Int32) then
  begin
    if (PInt32(@A)^   > PInt32(@B)^)   then Result :=  1 else
    if (PInt32(@A)^   < PInt32(@B)^)   then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(IntPtr) then
  begin
    if (PIntPtr(@A)^  > PIntPtr(@B)^)  then Result :=  1 else
    if (PIntPtr(@A)^  < PIntPtr(@B)^)  then Result := -1;
  end else
  begin
    case GetTypeData(TypeInfo(t)).OrdType of
      otUByte: if ((PUInt8 (@A)^) > (PUInt8 (@B)^)) then Result :=  1 else
               if ((PUInt8 (@A)^) < (PUInt8 (@B)^)) then Result := -1;
      otUWord: if ((PUInt16(@A)^) > (PUInt16(@B)^)) then Result :=  1 else
               if ((PUInt16(@A)^) < (PUInt16(@B)^)) then Result := -1;
      otULong: if ((PUInt32(@A)^) > (PUInt32(@B)^)) then Result :=  1 else
               if ((PUInt32(@A)^) < (PUInt32(@B)^)) then Result := -1;
      otSByte: if ((PInt8  (@A)^) > (PInt8  (@B)^)) then Result :=  1 else
               if ((PInt8  (@A)^) < (PInt8  (@B)^)) then Result := -1;
      otSWord: if ((PInt16 (@A)^) > (PInt16 (@B)^)) then Result :=  1 else
               if ((PInt16 (@A)^) < (PInt16 (@B)^)) then Result := -1;
      otSLong: if ((PInt32 (@A)^) > (PInt32 (@B)^)) then Result :=  1 else
               if ((PInt32 (@A)^) < (PInt32 (@B)^)) then Result := -1;
    end;
  end;
end;

class function TAtomicInteger<T>.GenericAdd(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then Result := ToGeneric(PUInt8  (@A)^ + PUInt8  (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt16 ) then Result := ToGeneric(PUInt16 (@A)^ + PUInt16 (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt32 ) then Result := ToGeneric(PUInt32 (@A)^ + PUInt32 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ + PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int8   ) then Result := ToGeneric(PInt8   (@A)^ + PInt8   (@B)^) else
  if TypeInfo(T) = TypeInfo(Int16  ) then Result := ToGeneric(PInt16  (@A)^ + PInt16  (@B)^) else
  if TypeInfo(T) = TypeInfo(Int32  ) then Result := ToGeneric(PInt32  (@A)^ + PInt32  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ + PIntPtr (@B)^) else
  begin
    case GetTypeData(TypeInfo(t)).OrdType of
      otUByte: Result := ToGeneric(PUInt8 (@A)^ + PUInt8 (@B)^);
      otUWord: Result := ToGeneric(PUInt16(@A)^ + PUInt16(@B)^);
      otULong: Result := ToGeneric(PUInt32(@A)^ + PUInt32(@B)^);
      otSByte: Result := ToGeneric(PInt8  (@A)^ + PInt8  (@B)^);
      otSWord: Result := ToGeneric(PInt16 (@A)^ + PInt16 (@B)^);
      otSLong: Result := ToGeneric(PInt32 (@A)^ + PInt32 (@B)^);
    end;
  end;
end;

class function TAtomicInteger<T>.GenericSub(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then Result := ToGeneric(PUInt8  (@A)^ - PUInt8  (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt16 ) then Result := ToGeneric(PUInt16 (@A)^ - PUInt16 (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt32 ) then Result := ToGeneric(PUInt32 (@A)^ - PUInt32 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ - PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int8   ) then Result := ToGeneric(PInt8   (@A)^ - PInt8   (@B)^) else
  if TypeInfo(T) = TypeInfo(Int16  ) then Result := ToGeneric(PInt16  (@A)^ - PInt16  (@B)^) else
  if TypeInfo(T) = TypeInfo(Int32  ) then Result := ToGeneric(PInt32  (@A)^ - PInt32  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ - PIntPtr (@B)^) else
  begin
    case GetTypeData(TypeInfo(t)).OrdType of
      otUByte: Result := ToGeneric(PUInt8 (@A)^ - PUInt8 (@B)^);
      otUWord: Result := ToGeneric(PUInt16(@A)^ - PUInt16(@B)^);
      otULong: Result := ToGeneric(PUInt32(@A)^ - PUInt32(@B)^);
      otSByte: Result := ToGeneric(PInt8  (@A)^ - PInt8  (@B)^);
      otSWord: Result := ToGeneric(PInt16 (@A)^ - PInt16 (@B)^);
      otSLong: Result := ToGeneric(PInt32 (@A)^ - PInt32 (@B)^);
    end;
  end;
end;

class function TAtomicInteger<T>.GenericMul(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then Result := ToGeneric(PUInt8  (@A)^ * PUInt8  (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt16 ) then Result := ToGeneric(PUInt16 (@A)^ * PUInt16 (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt32 ) then Result := ToGeneric(PUInt32 (@A)^ * PUInt32 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ * PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int8   ) then Result := ToGeneric(PInt8   (@A)^ * PInt8   (@B)^) else
  if TypeInfo(T) = TypeInfo(Int16  ) then Result := ToGeneric(PInt16  (@A)^ * PInt16  (@B)^) else
  if TypeInfo(T) = TypeInfo(Int32  ) then Result := ToGeneric(PInt32  (@A)^ * PInt32  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ * PIntPtr (@B)^) else
  begin
    case GetTypeData(TypeInfo(t)).OrdType of
      otUByte: Result := ToGeneric(PUInt8 (@A)^ * PUInt8 (@B)^);
      otUWord: Result := ToGeneric(PUInt16(@A)^ * PUInt16(@B)^);
      otULong: Result := ToGeneric(PUInt32(@A)^ * PUInt32(@B)^);
      otSByte: Result := ToGeneric(PInt8  (@A)^ * PInt8  (@B)^);
      otSWord: Result := ToGeneric(PInt16 (@A)^ * PInt16 (@B)^);
      otSLong: Result := ToGeneric(PInt32 (@A)^ * PInt32 (@B)^);
    end;
  end;
end;

class function TAtomicInteger<T>.GenericDiv(const A, B: T): Double;
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then Result := PUInt8  (@A)^ / PUInt8  (@B)^ else
  if TypeInfo(T) = TypeInfo(UInt16 ) then Result := PUInt16 (@A)^ / PUInt16 (@B)^ else
  if TypeInfo(T) = TypeInfo(UInt32 ) then Result := PUInt32 (@A)^ / PUInt32 (@B)^ else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := PUIntPtr(@A)^ / PUIntPtr(@B)^ else
  if TypeInfo(T) = TypeInfo(Int8   ) then Result := PInt8   (@A)^ / PInt8   (@B)^ else
  if TypeInfo(T) = TypeInfo(Int16  ) then Result := PInt16  (@A)^ / PInt16  (@B)^ else
  if TypeInfo(T) = TypeInfo(Int32  ) then Result := PInt32  (@A)^ / PInt32  (@B)^ else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := PIntPtr (@A)^ / PIntPtr (@B)^ else
  begin
    case GetTypeData(TypeInfo(t)).OrdType of
      otUByte: Result := PUInt8 (@A)^ / PUInt8 (@B)^;
      otUWord: Result := PUInt16(@A)^ / PUInt16(@B)^;
      otULong: Result := PUInt32(@A)^ / PUInt32(@B)^;
      otSByte: Result := PInt8  (@A)^ / PInt8  (@B)^;
      otSWord: Result := PInt16 (@A)^ / PInt16 (@B)^;
      otSLong: Result := PInt32 (@A)^ / PInt32 (@B)^;
    end;
  end;
end;

class function TAtomicInteger<T>.GenericIntDiv(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then Result := ToGeneric(PUInt8  (@A)^ div PUInt8  (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt16 ) then Result := ToGeneric(PUInt16 (@A)^ div PUInt16 (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt32 ) then Result := ToGeneric(PUInt32 (@A)^ div PUInt32 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ div PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int8   ) then Result := ToGeneric(PInt8   (@A)^ div PInt8   (@B)^) else
  if TypeInfo(T) = TypeInfo(Int16  ) then Result := ToGeneric(PInt16  (@A)^ div PInt16  (@B)^) else
  if TypeInfo(T) = TypeInfo(Int32  ) then Result := ToGeneric(PInt32  (@A)^ div PInt32  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ div PIntPtr (@B)^) else
  begin
    case GetTypeData(TypeInfo(t)).OrdType of
      otUByte: Result := ToGeneric(PUInt8 (@A)^ div PUInt8 (@B)^);
      otUWord: Result := ToGeneric(PUInt16(@A)^ div PUInt16(@B)^);
      otULong: Result := ToGeneric(PUInt32(@A)^ div PUInt32(@B)^);
      otSByte: Result := ToGeneric(PInt8  (@A)^ div PInt8  (@B)^);
      otSWord: Result := ToGeneric(PInt16 (@A)^ div PInt16 (@B)^);
      otSLong: Result := ToGeneric(PInt32 (@A)^ div PInt32 (@B)^);
    end;
  end;
end;

class function TAtomicInteger<T>.GenericMod(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then Result := ToGeneric(PUInt8  (@A)^ mod PUInt8  (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt16 ) then Result := ToGeneric(PUInt16 (@A)^ mod PUInt16 (@B)^) else
  if TypeInfo(T) = TypeInfo(UInt32 ) then Result := ToGeneric(PUInt32 (@A)^ mod PUInt32 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ mod PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int8   ) then Result := ToGeneric(PInt8   (@A)^ mod PInt8   (@B)^) else
  if TypeInfo(T) = TypeInfo(Int16  ) then Result := ToGeneric(PInt16  (@A)^ mod PInt16  (@B)^) else
  if TypeInfo(T) = TypeInfo(Int32  ) then Result := ToGeneric(PInt32  (@A)^ mod PInt32  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ mod PIntPtr (@B)^) else
  begin
    case GetTypeData(TypeInfo(t)).OrdType of
      otUByte: Result := ToGeneric(PUInt8 (@A)^ mod PUInt8 (@B)^);
      otUWord: Result := ToGeneric(PUInt16(@A)^ mod PUInt16(@B)^);
      otULong: Result := ToGeneric(PUInt32(@A)^ mod PUInt32(@B)^);
      otSByte: Result := ToGeneric(PInt8  (@A)^ mod PInt8  (@B)^);
      otSWord: Result := ToGeneric(PInt16 (@A)^ mod PInt16 (@B)^);
      otSLong: Result := ToGeneric(PInt32 (@A)^ mod PInt32 (@B)^);
    end;
  end;
end;

function TAtomicInteger<T>.GetOrdinal: TOrdinalType;
begin
  Result := FValue;
end;

function TAtomicInteger<T>.Get: T;
begin
  Result := ToGeneric(GetOrdinal);
end;

procedure TAtomicInteger<T>.Assign(const Value: T);
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then AtomicExchange(FValue, PUInt8  (@Value)^) else
  if TypeInfo(T) = TypeInfo(UInt16 ) then AtomicExchange(FValue, PUInt16 (@Value)^) else
  if TypeInfo(T) = TypeInfo(UInt32 ) then AtomicExchange(FValue, PUInt32 (@Value)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then AtomicExchange(FValue, PUIntPtr(@Value)^) else
  if TypeInfo(T) = TypeInfo(Int8   ) then AtomicExchange(FValue, PInt8   (@Value)^) else
  if TypeInfo(T) = TypeInfo(Int16  ) then AtomicExchange(FValue, PInt16  (@Value)^) else
  if TypeInfo(T) = TypeInfo(Int32  ) then AtomicExchange(FValue, PInt32  (@Value)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then AtomicExchange(FValue, PIntPtr (@Value)^) else
  begin
    AtomicExchange(FValue, ToOrdinal(Value) and OrdinalMask);
  end;
end;

function TAtomicInteger<T>.UnsafeGet: T;
begin
  Result := ToGeneric(FValue);
end;

procedure TAtomicInteger<T>.UnsafeAssign(const Value: T);
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then FValue := PUInt8  (@Value)^ else
  if TypeInfo(T) = TypeInfo(UInt16 ) then FValue := PUInt16 (@Value)^ else
  if TypeInfo(T) = TypeInfo(UInt32 ) then FValue := PUInt32 (@Value)^ else
  if TypeInfo(T) = TypeInfo(UIntPtr) then FValue := PUIntPtr(@Value)^ else
  if TypeInfo(T) = TypeInfo(Int8   ) then FValue := PInt8   (@Value)^ else
  if TypeInfo(T) = TypeInfo(Int16  ) then FValue := PInt16  (@Value)^ else
  if TypeInfo(T) = TypeInfo(Int32  ) then FValue := PInt32  (@Value)^ else
  if TypeInfo(T) = TypeInfo(IntPtr ) then FValue := PIntPtr (@Value)^ else
  begin
    FValue := ToOrdinal(Value) and OrdinalMask;
  end;
end;

function TAtomicInteger<T>.Exchange(const Value: T): T;
begin
  Result := ToGeneric(AtomicExchange(FValue, ToOrdinal(Value)));
end;

function TAtomicInteger<T>.CompareExchange(const Value, Comparand: T): T;
begin
  Result := ToGeneric(AtomicCmpExchange(FValue, ToOrdinal(Value), ToOrdinal(Comparand)));
end;

procedure TAtomicInteger<T>.Add(const Value: T);
begin
  AtomicIncrement(FValue, ToOrdinal(Value));
end;

procedure TAtomicInteger<T>.Sub(const Value: T);
begin
  AtomicDecrement(FValue, ToOrdinal(Value));
end;

procedure TAtomicInteger<T>.Inc;
begin
  AtomicIncrement(FValue);
end;

procedure TAtomicInteger<T>.Dec;
begin
  AtomicDecrement(FValue);
end;

class constructor TAtomicInteger<T>.Create;
begin
  CheckGenericType;
  OrdinalMask := (TOrdinalType(-1) shr ((SizeOf(TOrdinalType) - SizeOf(T)) * 8));
end;

class operator TAtomicInteger<T>.Implicit(const A: TAtomicInteger<T>): T;
begin
  Result := A.Get;
end;

class operator TAtomicInteger<T>.Implicit(const A: TAtomicInteger<T>): Single;
var
  D: Double;
begin
  D := A;
  Result := D;
end;

class operator TAtomicInteger<T>.Implicit(const A: TAtomicInteger<T>): Double;
begin
  if TypeInfo(T) = TypeInfo(UInt8  ) then Result := PUInt8  (@A.FValue)^ else
  if TypeInfo(T) = TypeInfo(UInt16 ) then Result := PUInt16 (@A.FValue)^ else
  if TypeInfo(T) = TypeInfo(UInt32 ) then Result := PUInt32 (@A.FValue)^ else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := PUIntPtr(@A.FValue)^ else
  if TypeInfo(T) = TypeInfo(Int8   ) then Result := PInt8   (@A.FValue)^ else
  if TypeInfo(T) = TypeInfo(Int16  ) then Result := PInt16  (@A.FValue)^ else
  if TypeInfo(T) = TypeInfo(Int32  ) then Result := PInt32  (@A.FValue)^ else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := PIntPtr (@A.FValue)^ else
  begin
    case GetTypeData(TypeInfo(t)).OrdType of
      otUByte: Result := UInt8 (A.GetOrdinal);
      otUWord: Result := UInt16(A.GetOrdinal);
      otULong: Result := UInt32(A.GetOrdinal);
      otSByte: Result := Int8  (A.GetOrdinal);
      otSWord: Result := Int16 (A.GetOrdinal);
      otSLong: Result := Int32 (A.GetOrdinal);
    end;
  end;
end;

class operator TAtomicInteger<T>.Explicit(const A: TAtomicInteger<T>): T;
begin
  Result := A;
end;

class operator TAtomicInteger<T>.Explicit(const A: TAtomicInteger<T>): Single;
begin
  Result := A;
end;

class operator TAtomicInteger<T>.Explicit(const A: TAtomicInteger<T>): Double;
begin
  Result := A;
end;

class operator TAtomicInteger<T>.Equal(const A, B: TAtomicInteger<T>): Boolean;
begin
  Result := (A.GetOrdinal = B.GetOrdinal);
end;

class operator TAtomicInteger<T>.Equal(const A: TAtomicInteger<T>; const B: T): Boolean;
begin
  Result := (A.GetOrdinal = ToOrdinal(B));
end;

class operator TAtomicInteger<T>.Equal(const A: T; const B: TAtomicInteger<T>): Boolean;
begin
  Result := (ToOrdinal(A) = B.GetOrdinal);
end;

class operator TAtomicInteger<T>.GreaterThan(const A, B: TAtomicInteger<T>): Boolean;
begin
  Result := (Compare(A.Get, B.Get) > 0);
end;

class operator TAtomicInteger<T>.GreaterThan(const A: TAtomicInteger<T>; const B: T): Boolean;
begin
  Result := (Compare(A.Get, B) > 0);
end;

class operator TAtomicInteger<T>.GreaterThan(const A: T; const B: TAtomicInteger<T>): Boolean;
begin
  Result := (Compare(A, B.Get) > 0);
end;

class operator TAtomicInteger<T>.GreaterThanOrEqual(const A, B: TAtomicInteger<T>): Boolean;
begin
  Result := (Compare(A.Get, B.Get) >= 0);
end;

class operator TAtomicInteger<T>.GreaterThanOrEqual(const A: TAtomicInteger<T>;
  const B: T): Boolean;
begin
  Result := (Compare(A.Get, B) >= 0);
end;

class operator TAtomicInteger<T>.GreaterThanOrEqual(const A: T;
  const B: TAtomicInteger<T>): Boolean;
begin
  Result := (Compare(A, B.Get) >= 0);
end;

class operator TAtomicInteger<T>.LessThan(const A, B: TAtomicInteger<T>): Boolean;
begin
  Result := (Compare(A.Get, B.Get) < 0);
end;

class operator TAtomicInteger<T>.LessThan(const A: TAtomicInteger<T>; const B: T): Boolean;
begin
  Result := (Compare(A.Get, B) < 0);
end;

class operator TAtomicInteger<T>.LessThan(const A: T; const B: TAtomicInteger<T>): Boolean;
begin
  Result := (Compare(A, B.Get) < 0);
end;

class operator TAtomicInteger<T>.LessThanOrEqual(const A, B: TAtomicInteger<T>): Boolean;
begin
  Result := (Compare(A.Get, B.Get) <= 0);
end;

class operator TAtomicInteger<T>.LessThanOrEqual(const A: TAtomicInteger<T>; const B: T): Boolean;
begin
  Result := (Compare(A.Get, B) <= 0);
end;

class operator TAtomicInteger<T>.LessThanOrEqual(const A: T; const B: TAtomicInteger<T>): Boolean;
begin
  Result := (Compare(A, B.Get) <= 0);
end;

class operator TAtomicInteger<T>.NotEqual(const A, B: TAtomicInteger<T>): Boolean;
begin
  Result := (A.GetOrdinal <> B.GetOrdinal);
end;

class operator TAtomicInteger<T>.NotEqual(const A: TAtomicInteger<T>; const B: T): Boolean;
begin
  Result := (A.GetOrdinal <> ToOrdinal(B));
end;

class operator TAtomicInteger<T>.NotEqual(const A: T; const B: TAtomicInteger<T>): Boolean;
begin
  Result := (ToOrdinal(A) <> B.GetOrdinal);
end;

class operator TAtomicInteger<T>.Negative(const A: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(-A.GetOrdinal);
end;

class operator TAtomicInteger<T>.Positive(const A: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal);
end;

class operator TAtomicInteger<T>.Add(const A, B: TAtomicInteger<T>): T;
begin
  Result := GenericAdd(A.Get, B.Get);
end;

class operator TAtomicInteger<T>.Add(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := GenericAdd(A.Get, B);
end;

class operator TAtomicInteger<T>.Add(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := GenericAdd(A, B.Get);
end;

class operator TAtomicInteger<T>.Subtract(const A, B: TAtomicInteger<T>): T;
begin
  Result := GenericSub(A.Get, B.Get);
end;

class operator TAtomicInteger<T>.Subtract(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := GenericSub(A.Get, B);
end;

class operator TAtomicInteger<T>.Subtract(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := GenericSub(A, B.Get);
end;

class operator TAtomicInteger<T>.Multiply(const A, B: TAtomicInteger<T>): T;
begin
  Result := GenericMul(A.Get, B.Get);
end;

class operator TAtomicInteger<T>.Multiply(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := GenericMul(A.Get, B);
end;

class operator TAtomicInteger<T>.Multiply(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := GenericMul(A, B.Get);
end;

class operator TAtomicInteger<T>.Divide(const A, B: TAtomicInteger<T>): Double;
begin
  Result := GenericDiv(A.Get, B.Get);
end;

class operator TAtomicInteger<T>.Divide(const A: TAtomicInteger<T>; const B: T): Double;
begin
  Result := GenericDiv(A.Get, B);
end;

class operator TAtomicInteger<T>.Divide(const A: T; const B: TAtomicInteger<T>): Double;
begin
  Result := GenericDiv(A, B.Get);
end;

class operator TAtomicInteger<T>.IntDivide(const A, B: TAtomicInteger<T>): T;
begin
  Result := GenericIntDiv(A.Get, B.Get);
end;

class operator TAtomicInteger<T>.IntDivide(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := GenericIntDiv(A.Get, B);
end;

class operator TAtomicInteger<T>.IntDivide(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := GenericIntDiv(A, B.Get);
end;

class operator TAtomicInteger<T>.Modulus(const A, B: TAtomicInteger<T>): T;
begin
  Result := GenericMod(A.Get, B.Get);
end;

class operator TAtomicInteger<T>.Modulus(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := GenericMod(A.Get, B);
end;

class operator TAtomicInteger<T>.Modulus(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := GenericMod(A, B.Get);
end;

class operator TAtomicInteger<T>.LeftShift(const A, B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal shl B.GetOrdinal);
end;

class operator TAtomicInteger<T>.LeftShift(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal shl ToOrdinal(B));
end;

class operator TAtomicInteger<T>.LeftShift(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) shl B.GetOrdinal);
end;

class operator TAtomicInteger<T>.RightShift(const A, B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal shr B.GetOrdinal);
end;

class operator TAtomicInteger<T>.RightShift(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal shr ToOrdinal(B));
end;

class operator TAtomicInteger<T>.RightShift(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) shr B.GetOrdinal);
end;

class operator TAtomicInteger<T>.BitwiseAnd(const A, B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal and B.GetOrdinal);
end;

class operator TAtomicInteger<T>.BitwiseAnd(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal and ToOrdinal(B));
end;

class operator TAtomicInteger<T>.BitwiseAnd(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) and B.GetOrdinal);
end;

class operator TAtomicInteger<T>.BitwiseOr(const A, B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal or B.GetOrdinal);
end;

class operator TAtomicInteger<T>.BitwiseOr(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal or ToOrdinal(B));
end;

class operator TAtomicInteger<T>.BitwiseOr(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) or B.GetOrdinal);
end;

class operator TAtomicInteger<T>.BitwiseXor(const A, B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal xor B.GetOrdinal);
end;

class operator TAtomicInteger<T>.BitwiseXor(const A: TAtomicInteger<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal xor ToOrdinal(B));
end;

class operator TAtomicInteger<T>.BitwiseXor(const A: T; const B: TAtomicInteger<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) xor B.GetOrdinal);
end;
{$ENDREGION}

{$REGION 'Class: TAtomicInteger64<T> '}
class procedure TAtomicInteger64<T>.CheckGenericType;
begin
  Assert(PTypeInfo(TypeInfo(T))^.Kind in [tkInt64],
    'Unsupported generic type.');
  Assert(SizeOf(T) = 8);
end;

class function TAtomicInteger64<T>.ToGeneric(const Value: TOrdinalType): T;
begin
  Result := PGenericType(@Value)^;
end;

class function TAtomicInteger64<T>.ToOrdinal(const Value: T): TOrdinalType;
begin
  Result := POrdinalType(@Value)^;
end;

class function TAtomicInteger64<T>.Compare(const A, B: T): Integer;
begin
  Result := 0;
  if TypeInfo(T) = TypeInfo(UInt64) then
  begin
    if (PUInt64(@A)^  > PUInt64(@B)^)  then Result :=  1 else
    if (PUInt64(@A)^  < PUInt64(@B)^)  then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(UIntPtr) then
  begin
    if (PUIntPtr(@A)^ > PUIntPtr(@B)^) then Result :=  1 else
    if (PUIntPtr(@A)^ < PUIntPtr(@B)^) then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(Int64) then
  begin
    if (PInt64(@A)^  > PInt64(@B)^)    then Result :=  1 else
    if (PInt64(@A)^  < PInt64(@B)^)    then Result := -1;
  end else
  if TypeInfo(T) = TypeInfo(IntPtr) then
  begin
    if (PIntPtr(@A)^ > PIntPtr(@B)^)   then Result :=  1 else
    if (PIntPtr(@A)^ < PIntPtr(@B)^)   then Result := -1;
  end else
  begin
    if (GetTypeData(TypeInfo(T)).MinInt64Value = 0) then
    begin
      if (PUInt64(@A)^ > PUInt64(@B)^) then Result :=  1 else
      if (PUInt64(@A)^ < PUInt64(@B)^) then Result := -1;
    end else
    begin
      if (PInt64(@A)^  > PInt64(@B)^)  then Result :=  1 else
      if (PInt64(@A)^  < PInt64(@B)^)  then Result := -1;
    end;
  end;
end;

class function TAtomicInteger64<T>.GenericAdd(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt64 ) then Result := ToGeneric(PUInt64 (@A)^ + PUInt64 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ + PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int64  ) then Result := ToGeneric(PInt64  (@A)^ + PInt64  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ + PIntPtr (@B)^) else
  begin
    if (GetTypeData(TypeInfo(T)).MinInt64Value = 0) then
    begin
      Result := ToGeneric(PUInt64(@A)^ + PUInt64(@B)^);
    end else
    begin
      Result := ToGeneric(PInt64 (@A)^ + PInt64 (@B)^);
    end;
  end;
end;

class function TAtomicInteger64<T>.GenericSub(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt64 ) then Result := ToGeneric(PUInt64 (@A)^ - PUInt64 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ - PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int64  ) then Result := ToGeneric(PInt64  (@A)^ - PInt64  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ - PIntPtr (@B)^) else
  begin
    if (GetTypeData(TypeInfo(T)).MinInt64Value = 0) then
    begin
      Result := ToGeneric(PUInt64(@A)^ - PUInt64(@B)^);
    end else
    begin
      Result := ToGeneric(PInt64 (@A)^ - PInt64 (@B)^);
    end;
  end;
end;

class function TAtomicInteger64<T>.GenericMul(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt64 ) then Result := ToGeneric(PUInt64 (@A)^ * PUInt64 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ * PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int64  ) then Result := ToGeneric(PInt64  (@A)^ * PInt64  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ * PIntPtr (@B)^) else
  begin
    if (GetTypeData(TypeInfo(T)).MinInt64Value = 0) then
    begin
      Result := ToGeneric(PUInt64(@A)^ * PUInt64(@B)^);
    end else
    begin
      Result := ToGeneric(PInt64 (@A)^ * PInt64 (@B)^);
    end;
  end;
end;

class function TAtomicInteger64<T>.GenericDiv(const A, B: T): Double;
begin
  if TypeInfo(T) = TypeInfo(UInt64 ) then Result := PUInt64 (@A)^ / PUInt64 (@B)^ else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := PUIntPtr(@A)^ / PUIntPtr(@B)^ else
  if TypeInfo(T) = TypeInfo(Int64  ) then Result := PInt64  (@A)^ / PInt64  (@B)^ else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := PIntPtr (@A)^ / PIntPtr (@B)^ else
  begin
    if (GetTypeData(TypeInfo(T)).MinInt64Value = 0) then
    begin
      Result := PUInt64(@A)^ / PUInt64(@B)^;
    end else
    begin
      Result := PInt64 (@A)^ / PInt64 (@B)^;
    end;
  end;
end;

class function TAtomicInteger64<T>.GenericIntDiv(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt64 ) then Result := ToGeneric(PUInt64 (@A)^ div PUInt64 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ div PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int64  ) then Result := ToGeneric(PInt64  (@A)^ div PInt64  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ div PIntPtr (@B)^) else
  begin
    if (GetTypeData(TypeInfo(T)).MinInt64Value = 0) then
    begin
      Result := ToGeneric(PUInt64(@A)^ div PUInt64(@B)^);
    end else
    begin
      Result := ToGeneric(PInt64 (@A)^ div PInt64 (@B)^);
    end;
  end;
end;

class function TAtomicInteger64<T>.GenericMod(const A, B: T): T;
begin
  if TypeInfo(T) = TypeInfo(UInt64 ) then Result := ToGeneric(PUInt64 (@A)^ mod PUInt64 (@B)^) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := ToGeneric(PUIntPtr(@A)^ mod PUIntPtr(@B)^) else
  if TypeInfo(T) = TypeInfo(Int64  ) then Result := ToGeneric(PInt64  (@A)^ mod PInt64  (@B)^) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := ToGeneric(PIntPtr (@A)^ mod PIntPtr (@B)^) else
  begin
    if (GetTypeData(TypeInfo(T)).MinInt64Value = 0) then
    begin
      Result := ToGeneric(PUInt64(@A)^ mod PUInt64(@B)^);
    end else
    begin
      Result := ToGeneric(PInt64 (@A)^ mod PInt64 (@B)^);
    end;
  end;
end;

function TAtomicInteger64<T>.GetOrdinal: TOrdinalType;
begin
  Result := AtomicCmpExchange(FValue, 0, 0);
end;

function TAtomicInteger64<T>.Get: T;
begin
  Result := ToGeneric(GetOrdinal);
end;

procedure TAtomicInteger64<T>.Assign(const Value: T);
begin
  AtomicExchange(FValue, ToOrdinal(Value));
end;

function TAtomicInteger64<T>.UnsafeGet: T;
begin
  Result := ToGeneric(FValue);
end;

procedure TAtomicInteger64<T>.UnsafeAssign(const Value: T);
begin
  FValue := ToOrdinal(Value);
end;

function TAtomicInteger64<T>.Exchange(const Value: T): T;
begin
  Result := ToGeneric(AtomicExchange(FValue, ToOrdinal(Value)));
end;

function TAtomicInteger64<T>.CompareExchange(const Value, Comparand: T): T;
begin
  Result := ToGeneric(AtomicCmpExchange(FValue, ToOrdinal(Value), ToOrdinal(Comparand)));
end;

procedure TAtomicInteger64<T>.Add(const Value: T);
begin
  AtomicIncrement(FValue, ToOrdinal(Value));
end;

procedure TAtomicInteger64<T>.Sub(const Value: T);
begin
  AtomicDecrement(FValue, ToOrdinal(Value));
end;

procedure TAtomicInteger64<T>.Inc;
begin
  AtomicIncrement(FValue);
end;

procedure TAtomicInteger64<T>.Dec;
begin
  AtomicDecrement(FValue);
end;

class constructor TAtomicInteger64<T>.Create;
begin
  CheckGenericType;
end;

class operator TAtomicInteger64<T>.Implicit(const A: TAtomicInteger64<T>): T;
begin
  Result := A.Get;
end;

class operator TAtomicInteger64<T>.Implicit(const A: TAtomicInteger64<T>): Single;
var
  D: Double;
begin
  D := A;
  Result := D;
end;

class operator TAtomicInteger64<T>.Implicit(const A: TAtomicInteger64<T>): Double;
begin
  if TypeInfo(T) = TypeInfo(UInt64 ) then Result := UInt64 (A.GetOrdinal) else
  if TypeInfo(T) = TypeInfo(UIntPtr) then Result := UIntPtr(A.GetOrdinal) else
  if TypeInfo(T) = TypeInfo(Int64  ) then Result := Int64  (A.GetOrdinal) else
  if TypeInfo(T) = TypeInfo(IntPtr ) then Result := IntPtr (A.GetOrdinal) else
  begin
    if (GetTypeData(TypeInfo(T)).MinInt64Value = 0) then
    begin
      Result := UInt64(A.GetOrdinal);
    end else
    begin
      Result := Int64(A.GetOrdinal);
    end;
  end;
end;

class operator TAtomicInteger64<T>.Explicit(const A: TAtomicInteger64<T>): T;
begin
  Result := A;
end;

class operator TAtomicInteger64<T>.Explicit(const A: TAtomicInteger64<T>): Single;
begin
  Result := A;
end;

class operator TAtomicInteger64<T>.Explicit(const A: TAtomicInteger64<T>): Double;
begin
  Result := A;
end;

class operator TAtomicInteger64<T>.Equal(const A, B: TAtomicInteger64<T>): Boolean;
begin
  Result := (A.GetOrdinal = B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.Equal(const A: TAtomicInteger64<T>; const B: T): Boolean;
begin
  Result := (A.GetOrdinal = ToOrdinal(B));
end;

class operator TAtomicInteger64<T>.Equal(const A: T; const B: TAtomicInteger64<T>): Boolean;
begin
  Result := (ToOrdinal(A) = B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.GreaterThan(const A, B: TAtomicInteger64<T>): Boolean;
begin
  Result := (Compare(A.Get, B.Get) > 0);
end;

class operator TAtomicInteger64<T>.GreaterThan(const A: TAtomicInteger64<T>; const B: T): Boolean;
begin
  Result := (Compare(A.Get, B) > 0);
end;

class operator TAtomicInteger64<T>.GreaterThan(const A: T; const B: TAtomicInteger64<T>): Boolean;
begin
  Result := (Compare(A, B.Get) > 0);
end;

class operator TAtomicInteger64<T>.GreaterThanOrEqual(const A, B: TAtomicInteger64<T>): Boolean;
begin
  Result := (Compare(A.Get, B.Get) >= 0);
end;

class operator TAtomicInteger64<T>.GreaterThanOrEqual(const A: TAtomicInteger64<T>;
  const B: T): Boolean;
begin
  Result := (Compare(A.Get, B) >= 0);
end;

class operator TAtomicInteger64<T>.GreaterThanOrEqual(const A: T;
  const B: TAtomicInteger64<T>): Boolean;
begin
  Result := (Compare(A, B.Get) >= 0);
end;

class operator TAtomicInteger64<T>.LessThan(const A, B: TAtomicInteger64<T>): Boolean;
begin
  Result := (Compare(A.Get, B.Get) < 0);
end;

class operator TAtomicInteger64<T>.LessThan(const A: TAtomicInteger64<T>; const B: T): Boolean;
begin
  Result := (Compare(A.Get, B) < 0);
end;

class operator TAtomicInteger64<T>.LessThan(const A: T; const B: TAtomicInteger64<T>): Boolean;
begin
  Result := (Compare(A, B.Get) < 0);
end;

class operator TAtomicInteger64<T>.LessThanOrEqual(const A, B: TAtomicInteger64<T>): Boolean;
begin
  Result := (Compare(A.Get, B.Get) <= 0);
end;

class operator TAtomicInteger64<T>.LessThanOrEqual(const A: TAtomicInteger64<T>;
  const B: T): Boolean;
begin
  Result := (Compare(A.Get, B) <= 0);
end;

class operator TAtomicInteger64<T>.LessThanOrEqual(const A: T;
  const B: TAtomicInteger64<T>): Boolean;
begin
  Result := (Compare(A, B.Get) <= 0);
end;

class operator TAtomicInteger64<T>.NotEqual(const A, B: TAtomicInteger64<T>): Boolean;
begin
  Result := (A.GetOrdinal <> B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.NotEqual(const A: TAtomicInteger64<T>; const B: T): Boolean;
begin
  Result := (A.GetOrdinal <> ToOrdinal(B));
end;

class operator TAtomicInteger64<T>.NotEqual(const A: T; const B: TAtomicInteger64<T>): Boolean;
begin
  Result := (ToOrdinal(A) <> B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.Negative(const A: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(-A.GetOrdinal);
end;

class operator TAtomicInteger64<T>.Positive(const A: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal);
end;

class operator TAtomicInteger64<T>.Add(const A, B: TAtomicInteger64<T>): T;
begin
  Result := GenericAdd(A.Get, B.Get);
end;

class operator TAtomicInteger64<T>.Add(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := GenericAdd(A.Get, B);
end;

class operator TAtomicInteger64<T>.Add(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := GenericAdd(A, B.Get);
end;

class operator TAtomicInteger64<T>.Subtract(const A, B: TAtomicInteger64<T>): T;
begin
  Result := GenericSub(A.Get, B.Get);
end;

class operator TAtomicInteger64<T>.Subtract(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := GenericSub(A.Get, B);
end;

class operator TAtomicInteger64<T>.Subtract(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := GenericSub(A, B.Get);
end;

class operator TAtomicInteger64<T>.Multiply(const A, B: TAtomicInteger64<T>): T;
begin
  Result := GenericMul(A.Get, B.Get);
end;

class operator TAtomicInteger64<T>.Multiply(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := GenericMul(A.Get, B);
end;

class operator TAtomicInteger64<T>.Multiply(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := GenericMul(A, B.Get);
end;

class operator TAtomicInteger64<T>.Divide(const A, B: TAtomicInteger64<T>): Double;
begin
  Result := GenericDiv(A.Get, B.Get);
end;

class operator TAtomicInteger64<T>.Divide(const A: TAtomicInteger64<T>; const B: T): Double;
begin
  Result := GenericDiv(A.Get, B);
end;

class operator TAtomicInteger64<T>.Divide(const A: T; const B: TAtomicInteger64<T>): Double;
begin
  Result := GenericDiv(A, B.Get);
end;

class operator TAtomicInteger64<T>.IntDivide(const A, B: TAtomicInteger64<T>): T;
begin
  Result := GenericIntDiv(A.Get, B.Get);
end;

class operator TAtomicInteger64<T>.IntDivide(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := GenericIntDiv(A.Get, B);
end;

class operator TAtomicInteger64<T>.IntDivide(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := GenericIntDiv(A, B.Get);
end;

class operator TAtomicInteger64<T>.Modulus(const A, B: TAtomicInteger64<T>): T;
begin
  Result := GenericMod(A.Get, B.Get);
end;

class operator TAtomicInteger64<T>.Modulus(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := GenericMod(A.Get, B);
end;

class operator TAtomicInteger64<T>.Modulus(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := GenericMod(A, B.Get);
end;

class operator TAtomicInteger64<T>.LeftShift(const A, B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal shl B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.LeftShift(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal shl ToOrdinal(B));
end;

class operator TAtomicInteger64<T>.LeftShift(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) shl B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.RightShift(const A, B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal shr B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.RightShift(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal shr ToOrdinal(B));
end;

class operator TAtomicInteger64<T>.RightShift(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) shr B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.BitwiseAnd(const A, B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal and B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.BitwiseAnd(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal and ToOrdinal(B));
end;

class operator TAtomicInteger64<T>.BitwiseAnd(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) and B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.BitwiseOr(const A, B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal or B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.BitwiseOr(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal or ToOrdinal(B));
end;

class operator TAtomicInteger64<T>.BitwiseOr(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) or B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.BitwiseXor(const A, B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(A.GetOrdinal xor B.GetOrdinal);
end;

class operator TAtomicInteger64<T>.BitwiseXor(const A: TAtomicInteger64<T>; const B: T): T;
begin
  Result := ToGeneric(A.GetOrdinal xor ToOrdinal(B));
end;

class operator TAtomicInteger64<T>.BitwiseXor(const A: T; const B: TAtomicInteger64<T>): T;
begin
  Result := ToGeneric(ToOrdinal(A) xor B.GetOrdinal);
end;
{$ENDREGION}

end.
