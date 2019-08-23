package wasp.types;

/**
 * Import is an interface implemented by types that can be imported by a WebAssembly module.
 */
interface ImportType extends Marshaller {
    function kind():External;
    function isImport():Void;
    
}