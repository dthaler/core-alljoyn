package org.alljoyn.bus.defs;

/**
 * Argument definition used to describe a method or signal argument.
 * Annotations commonly used: DocString, VariantTypes.
 */
public class ArgDef extends BaseDef {

    /* Argument direction values */
    public static final String DIRECTION_IN = "in";
    public static final String DIRECTION_OUT = "out";

    final private String type;
    final private String direction;


    /**
     * Constructor. Represents an argument in a method or signal. Direction defaults to 'in'.
     *
     * @param name the name of the argument.
     * @param type the signature of the argument (represented by characters: y,b,n,q,i,u,x,t,d,s,o,g,a,r,v).
     *             @see dbus.freedesktop.org/doc/dbus-specification.html#idp94392448
     * @throws IllegalArgumentException one or more arguments is invalid.
     */
    public ArgDef(String name, String type) {
        this(name, type, DIRECTION_IN);
    }

    /**
     * Constructor. Represents an argument in a method or signal.
     *
     * @param name the name of the argument.
     * @param type the signature of the argument (represented by characters: y,b,n,q,i,u,x,t,d,s,o,g,a,r,v).
     *             @see dbus.freedesktop.org/doc/dbus-specification.html#idp94392448
     * @param direction the direction of the argument (one of: in, out).
     *                  The direction 'unset' may be used internally only.
     * @throws IllegalArgumentException one or more arguments is invalid.
     */
    public ArgDef(String name, String type, String direction) {
        super(name);
        if (type == null || type.isEmpty()) {
            throw new IllegalArgumentException("Null or empty type");
        }
        if (direction == null ||
                !(direction.equalsIgnoreCase(DIRECTION_IN) || direction.equalsIgnoreCase(DIRECTION_OUT))) {
            throw new IllegalArgumentException("Null or unknown direction");
        }
        this.type = type;
        this.direction = direction;
    }

    /**
     * Get the arg type, represented as a signature.
     *
     * @return the signature of the arg (represented by characters: y,b,n,q,i,u,x,t,d,s,o,g,a,r,v).
     */
    public String getType() {
        return type;
    }

    /**
     * Get the arg direction. The direction 'unset' may be used internally only.
     *
     * @return the argument direction (either 'in' or 'out').
     */
    public String getDirection() {
        return direction;
    }

    /**
     * @return whether this is an 'in' arg.
     */
    public boolean isInArg() {
        return direction.equalsIgnoreCase(DIRECTION_IN);
    }

    /**
     * @return whether this is an 'out' arg.
     */
    public boolean isOutArg() {
        return direction.equalsIgnoreCase(DIRECTION_OUT);
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("ArgDef {name=");
        builder.append(getName());
        builder.append(", type=");
        builder.append(type);
        builder.append(", direction=");
        builder.append(direction);
        builder.append("}");
        return builder.toString();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ArgDef argDef = (ArgDef) o;

        if (!getName().equals(argDef.getName())) return false;
        return direction.equals(argDef.direction);
    }

    @Override
    public int hashCode() {
        int result = getName().hashCode();
        result = 31 * result + direction.hashCode();
        return result;
    }

}